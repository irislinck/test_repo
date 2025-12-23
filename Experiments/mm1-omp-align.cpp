// Compile this code :
// icpx -O3 -march=core-avx2 -qopenmp -Rpass=loop-vectorize -g -o mm1-omp-O3-avx mm1-omp-align.cpp

/* This version is using:
Using double** (array of pointers) doesn't guarantee alignment. 
Instead, use contiguous flat arrays (e.g., double* a) and simulate 2D access with a[i * n + j].
Use aligned_alloc or _mm_malloc (Intel-specific) to ensure alignment. Example using aligned_alloc
*/
#include <iostream>
#include <iomanip>
#include <cmath>
#include <omp.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h> 
#include <unistd.h>
#include <cstdlib>

using namespace std;

bool GetUserInput(int argc, char *argv[], int &n, int &isPrint)
{
    bool isOK = true;
    if (argc < 2)
    {
        cout << "Inform 2 Arguments:" << endl;
        cout << "X : Matrix size [X x X]" << endl;
        cout << "Y = 1: print the input/output matrix if X < 10" << endl;
        isOK = false;
    }
    else
    {
        n = atoi(argv[1]);
        if (n <= 0)
        {
            cout << "Matrix size must be larger than 0" << endl;
            isOK = false;
        }
        if (argc >= 3)
            isPrint = (atoi(argv[2]) == 1 && n <= 10) ? 1 : 0;
        else
            isPrint = 0;
    }
    return isOK;
}

double *AlignedMatrixAlloc(int n, double value)
{
    double *x = (double *)aligned_alloc(32, n * n * sizeof(double));
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            x[i * n + j] = (value == 0.0) ? 0.0 : ((i + 2) + (j + 3)) + 5;
    return x;
}

void PrintMatrix(double *x, int n)
{
    for (int i = 0; i < n; i++)
    {
        cout << "Row " << (i + 1) << ":\t";
        for (int j = 0; j < n; j++)
            printf("%.2f\t", x[i * n + j]);
        cout << endl;
    }
}

void ParallelMatrixMultiplication(double *a, double *b, double *c, int n)
{
    printf("Parallel Version of Matrix Multiplication - OpenMP with %d threads\n", omp_get_max_threads());
    #pragma omp parallel for
    for (int i = 0; i < n; i++)
    {
        for (int k = 0; k < n; k++)
        {
            #pragma vector aligned
            for (int j = 0; j < n; j++)
            {
                c[i * n + j] += a[i * n + k] * b[k * n + j];
            }
        }
    }
}

int main(int argc, char *argv[])
{
    int n, isPrint;
    double runtime;

    if (!GetUserInput(argc, argv, n, isPrint))
        return 1;

    double *a = AlignedMatrixAlloc(n, 1.0);
    double *b = AlignedMatrixAlloc(n, 1.0);
    double *c = AlignedMatrixAlloc(n, 0.0);

    if (isPrint == 1)
    {
        cout << "Matrix a[n][n]:" << endl;
        PrintMatrix(a, n);
        cout << "Matrix b[n][n]:" << endl;
        PrintMatrix(b, n);
    }

    const int nt = omp_get_max_threads();
    if (nt <= 1)
        printf("This program is running in sequential mode\n");
    else
        printf("OpenMP code will run with %d threads based on OMP_NUM_THREADS\n", nt);

    printf("This node has available %ld logical processors.\n", sysconf(_SC_NPROCESSORS_ONLN));

    runtime = omp_get_wtime();
    ParallelMatrixMultiplication(a, b, c, n);
    runtime = omp_get_wtime() - runtime;

    if (isPrint == 1)
    {
        cout << "Output matrix:" << endl;
        PrintMatrix(c, n);
    }

    cout << "Program runs in " << setiosflags(ios::fixed) << setprecision(2) << runtime << " seconds\n";

    free(a);
    free(b);
    free(c);
    return 0;
}

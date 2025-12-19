# Import type hints for generic programming
from collections.abc import Iterable
from typing import TypeVar, List

# Define a generic type variable constrained to int or float for numeric operations
T = TypeVar("T", int, float)


def prefix_sums(values: Iterable[T]) -> List[T]:
	"""
	Return prefix sums with a leading 0 in O(n) time.
	
	Args:
	    values: An iterable of numeric values (int or float)
	    
	Returns:
	    A list of cumulative sums, starting with 0
	    
	Example:
	    prefix_sums([1, 2, 3, 4]) -> [0, 1, 3, 6, 10]
	"""
	# Initialize total to 0 (will be the first element in result)
	total: T = 0
	# Start result list with leading 0
	result: List[T] = [total]
	
	# Iterate through each value and accumulate the sum
	for v in values:
		# Add current value to running total
		total += v
		# Append cumulative sum to result
		result.append(total)
	
	return result


if __name__ == "__main__":
	# Example usage
	print(prefix_sums([1, 2, 3, 4]))

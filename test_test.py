import pytest
from test import prefix_sums

def test_prefix_sums_basic():
    """Test with basic integer list."""
    assert prefix_sums([1, 2, 3, 4]) == [0, 1, 3, 6, 10]


def test_prefix_sums_empty():
    """Test with empty iterable."""
    assert prefix_sums([]) == [0]


def test_prefix_sums_single_element():
    """Test with single element."""
    assert prefix_sums([5]) == [0, 5]


def test_prefix_sums_floats():
    """Test with float values."""
    assert prefix_sums([1.5, 2.5, 3.0]) == [0, 1.5, 4.0, 7.0]


def test_prefix_sums_negative():
    """Test with negative numbers."""
    assert prefix_sums([-1, 2, -3, 4]) == [0, -1, 1, -2, 2]


def test_prefix_sums_zeros():
    """Test with zeros."""
    assert prefix_sums([0, 0, 0]) == [0, 0, 0, 0]


def test_prefix_sums_tuple_input():
    """Test with tuple input (iterable)."""
    assert prefix_sums((1, 2, 3)) == [0, 1, 3, 6]
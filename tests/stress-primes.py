import time
import math

def is_prime(n):
    if n <= 1:
        return False
    if n <= 3:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def stress_test(limit):
    start_time = time.time()
    count = 0
    num = 2
    while count < limit:
        if is_prime(num):
            count += 1
            # Perform a heavy computation
            _ = num ** (num % 10)
        num += 1
    end_time = time.time()
    print(f"Found {limit} prime numbers in {end_time - start_time} seconds.")

# Run the stress test with a limit of 1000 prime numbers
stress_test(1000)

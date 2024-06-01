import argparse
import random

class Product:
    ID = 0
    duration = 0
    expiration = 0
    priority = 0

    def __init__(self, ID, duration, expiration, priority):
        self.ID = ID
        self.duration = duration
        self.expiration = expiration
        self.priority = priority

    def calculatePenal(self, time):
        return self.priority*(time-self.expiration)

    def __str__(self):
        return f"{self.ID},{self.duration},{self.expiration},{self.priority}\n"
MAX_ID = 127
MAX_PRIORITY = 5
MAX_EXPIRATION = 100
MAX_DURATION = 10


def positive_int(value):
    ivalue = int(value)
    if ivalue <= 0:
        raise argparse.ArgumentTypeError(
            "%s is not a positive integer" % value)
    return ivalue




def generate_test_cases(num_test_cases, max_priority=None, max_expiration=None, max_duration=None):
    if (not max_priority):
        max_priority = MAX_PRIORITY
    if (not max_expiration):
        max_expiration = MAX_EXPIRATION
    if (not max_duration):
        max_duration = MAX_DURATION
    test_cases = {}
    for id in range(num_test_cases):
        duration = random.randint(1, max_duration)
        expiration = random.randint(1, max_expiration)
        priority = random.randint(1, max_priority)
        test_cases[id] = Product(id, duration, expiration, priority)
    return test_cases


def write_test_cases_to_file(filename, test_cases):
    with open(filename, 'w', encoding='utf-8') as file:
        for i in test_cases:
            test_case = test_cases[i]
            file.write(str(test_case))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Generate test cases and write them to a file')
    parser.add_argument('num_test_cases', type=positive_int,
                        help='Number of test cases')
    parser.add_argument('--max_priority', type=positive_int,
                        help='Maximum number of priorities')
    parser.add_argument('--max_ids', type=positive_int,
                        help='Maximum number of priorities')
    parser.add_argument('--max_expiration', type=positive_int,
                        help='Maximum number of expirations')
    parser.add_argument('--max_duration', type=positive_int,
                        help='Maximum number of durations')
    parser.add_argument('--filename', type=str,
                        default='test_cases.txt', help='Name of the output file')
    args = parser.parse_args()

    # test wether there are more ids then test cases
    assert ((MAX_ID if not args.max_ids else args.max_ids) > args.num_test_cases)

    test_cases = generate_test_cases(
        args.num_test_cases, args.max_priority, args.max_expiration, args.max_duration)
    write_test_cases_to_file(args.filename, test_cases)
    print(f"Test cases written to {args.filename}")

import argparse
import numpy as np


def hello():
    def name(v):
        if not v:
            raise ValueError("name cannot be empty")
        else:
            return v

    # Add arguments
    parser = argparse.ArgumentParser(description="hello world application")
    parser.add_argument("name", type=name,
                        help="name to greet")
    parser.add_argument("-e", "--exclamation",
                        action="store_true", help="append an exclamation mark")

    # Parse arguments
    args = parser.parse_args()

    # Hello
    print(f"Hello {args.name}{'!' if args.exclamation else ''}")


def add_i32():
    # Add arguments
    parser = argparse.ArgumentParser(description="add i32 numbers")
    parser.add_argument("num", type=np.int32, nargs="+", help="numbers to add")

    # Parse arguments
    args = parser.parse_args()

    # Add
    result = np.sum(args.num, dtype=np.int32)
    equation = " + ".join([f"{n}" for n in args.num])
    print(f"{equation} = {result}")

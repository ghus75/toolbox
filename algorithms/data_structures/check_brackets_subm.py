# python3

from collections import namedtuple

Bracket = namedtuple("Bracket", ["char", "position"])


def are_matching(left, right):
    return (left + right) in ["()", "[]", "{}"]


def find_mismatch(text):
    '''
    Finds mismatches in brackets
    Brackets are represented as namedtuples and put into lists used as stacks
    '''
    opening_brackets_stack = []
    closing_brackets_stack = []
    for i, next in enumerate(text):
        if next in "([{":
            # Process opening bracket
            opening_bracket = Bracket(next, i + 1)
            opening_brackets_stack.append(opening_bracket)

        if next in ")]}":
            # Process closing bracket
            closing_bracket = Bracket(next, i + 1) 
            # if at least 1 unmatched closing bracket : return its position
            if opening_brackets_stack == []: return closing_bracket.position
            closing_brackets_stack.append(closing_bracket)
            most_recent_opening_bracket = opening_brackets_stack.pop()
            if not are_matching(most_recent_opening_bracket.char,\
                                closing_bracket.char):
                    return closing_bracket.position
    # if at least 1 unmatched opening bracket : return its position
    if opening_brackets_stack == [] : return None
    else: return opening_brackets_stack.pop().position


def main():
    '''
    Find if there are unmatched brackets in code
    Uses stack to compare opening and closing brackets
    Ouputs first position of unmatched bracket
    
    Good job! (Max time used: 0.17/5.00, max memory used: 12361728/536870912.)
    '''
    text = input()
    mismatch = find_mismatch(text)
    
    if mismatch == None: print('Success')
    else: print(mismatch)


if __name__ == "__main__":
    main()


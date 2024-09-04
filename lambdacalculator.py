calc = lambda a: lambda b: lambda op: (
    (a + b) if op == 'add' else
    (a - b) if op == 'subtract' else
    (a * b) if op == 'multiply' else
    (a / b if b != 0 else 'Error: Division by zero') if op == 'divide' else
    (a ** b) if op == 'power' else
    (a % b) if op == 'modulo' else
    (a and b) if op == 'and' else
    (a or b) if op == 'or' else
    (not a) if op == 'not' and b is None else
    'Invalid operation'
)

# Creating a helper to call the calculator
def calculate(a, b=None, op=None):
    if b is not None:
        return calc(a)(b)(op)
    else:
        # If the operation is 'not', handle single argument cases
        return calc(a)(None)(op)

# Usage example with different operations
addition_result = calculate(5, 3, 'add')
subtraction_result = calculate(10, 7, 'subtract')
multiplication_result = calculate(6, 4, 'multiply')
division_result = calculate(8, 0, 'divide')  # Includes error handling for division by zero
power_result = calculate(2, 3, 'power')
modulo_result = calculate(10, 3, 'modulo')
and_result = calculate(True, False, 'and')
or_result = calculate(True, False, 'or')
not_result = calculate(True, None, 'not')
print(f"5 + 3 = {addition_result}")
print(f"10 - 7 = {subtraction_result}")
print(f"6 * 4 = {multiplication_result}")
print(f"8 / 0 = {division_result}")  # Error case
print(f"2 ^ 3 = {power_result}")
print(f"10 % 3 = {modulo_result}")
print(f"True AND False = {and_result}")  
print(f"True OR False = {or_result}")
print(f"NOT True = {not_result}")

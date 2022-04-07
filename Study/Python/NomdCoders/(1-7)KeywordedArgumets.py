# (1)
def say_hello(name, age):
  return f"Hello {name} you are {age} years old"

# (2)
def say_hello(name, age):
  return "Hello " + name + " you are " + age + "years old"

hello = say_hello(age="12", name="nico")
print(hello)

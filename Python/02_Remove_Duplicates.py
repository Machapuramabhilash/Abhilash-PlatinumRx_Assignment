
s = input("Enter string: ")
unique = ""
for ch in s:
    if ch not in unique:
        unique += ch
print(unique)

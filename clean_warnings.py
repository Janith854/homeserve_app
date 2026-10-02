import re

with open(r"C:\Users\Chamo\Desktop\homeserve_app\lib\screens\auth\login_screen.dart", "r", encoding="utf-8") as f:
    l_content = f.read()

# Fix unused userModel
l_content = re.sub(r'final userModel = await authService.login', r'await authService.login', l_content)

with open(r"C:\Users\Chamo\Desktop\homeserve_app\lib\screens\auth\login_screen.dart", "w", encoding="utf-8") as f:
    f.write(l_content)

with open(r"C:\Users\Chamo\Desktop\homeserve_app\lib\screens\auth\signup_screen.dart", "r", encoding="utf-8") as f:
    s_content = f.read()

# Remove unused fields
s_content = re.sub(r'final FirebaseAuth _auth.*?\n', '', s_content)
s_content = re.sub(r'final FirebaseFirestore _firestore.*?\n', '', s_content)

# Remove unused method _getFriendlyErrorMessage
s_content = re.sub(r'String _getFriendlyErrorMessage.*?}\n', '', s_content, flags=re.DOTALL)

with open(r"C:\Users\Chamo\Desktop\homeserve_app\lib\screens\auth\signup_screen.dart", "w", encoding="utf-8") as f:
    f.write(s_content)

print("Fixed warnings")

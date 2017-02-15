"""Python file holding emails to be sent"""

password_reset_txt = """
Hello {username},

Someone has requested a password reset link.

If this was you, please reset your password at

{url}

If not, please disregard this e-mail.

Thank you!
"""

user_registration_txt = """
Hello {user_firstname},

{created_by_name} from the {created_by_organization} organization has created a user ({username})
for you in the {created_organization} organization.

To complete registration please set your password at

{url}

Thank you!
"""

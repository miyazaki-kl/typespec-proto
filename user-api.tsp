import "@typespec/http";

using Http;

@service(#{ title: "User Management Service" })
namespace UserService;

@format("email")
scalar Email extends string;

@minLength(3)
@maxLength(30)
@pattern("^[a-zA-Z0-9_-]+$", "Must contain only letters, numbers, hyphens, and underscores")
scalar Username extends string;

@minLength(8)
@maxLength(100)
scalar Password extends string;

@maxLength(50)
scalar Name extends string;

@maxLength(500)
scalar Bio extends string;

@pattern("^\\+?[1-9]\\d{1,14}$", "Must be a valid international phone number")
scalar PhoneNumber extends string;

@minValue(0)
@maxValue(150)
scalar Age extends int32;

enum UserRole {
  admin: "admin",
  user: "user",
  moderator: "moderator"
}

enum UserStatus {
  active: "active",
  suspended: "suspended",
  inactive: "inactive",
  pending: "pending"
}

model User {
  id: string;
  email: Email;
  username: Username;
  firstName?: Name;
  lastName?: Name;
  age?: Age;
  avatarUrl?: string;
  role: UserRole;
  status: UserStatus;
  createdAt: utcDateTime;
  updatedAt: utcDateTime;
  lastLoginAt?: utcDateTime;
}

model CreateUserRequest {
  email: Email;
  username: Username;
  password: Password;
  firstName?: Name;
  lastName?: Name;
  age?: Age;
  role?: UserRole = UserRole.user;
}

model UpdateUserRequest {
  email?: Email;
  username?: Username;
  firstName?: Name;
  lastName?: Name;
  age?: Age;
  avatarUrl?: string;
  role?: UserRole;
  status?: UserStatus;
}

model ChangePasswordRequest {
  currentPassword: Password;
  newPassword: Password;
}

model ResetPasswordRequest {
  email: Email;
}

model UserProfile {
  ...User;
  phoneNumber?: PhoneNumber;
  bio?: Bio;
  location?: Name;
  website?: string;
}

model UserList {
  users: User[];
  total: int32;
  page: int32;
  pageSize: int32;
  hasNext: boolean;
  hasPrevious: boolean;
}

@error
model UserError {
  code: int32;
  message: string;
  field?: string;
}

model PasswordResetResponse {
  message: string;
  resetToken?: string;
}

@route("/users")
@tag("Users")
interface Users {
  /** List users with pagination and filtering */
  @get
  list(
    @query page?: int32 = 1,
    @query pageSize?: int32 = 20,
    @query role?: UserRole,
    @query status?: UserStatus,
    @query search?: string
  ): UserList | UserError;

  /** Get user by ID */
  @get
  read(@path id: string): User | UserError;

  /** Create new user */
  @post
  create(@body body: CreateUserRequest): User | UserError;

  /** Update user */
  @patch
  update(@path id: string, @body body: UpdateUserRequest): User | UserError;

  /** Delete user */
  @delete
  delete(@path id: string): void | UserError;

  /** Get detailed user profile */
  @route("{id}/profile")
  @get
  getProfile(@path id: string): UserProfile | UserError;

  /** Change user password */
  @route("{id}/change-password")
  @post
  changePassword(@path id: string, @body body: ChangePasswordRequest): void | UserError;

  /** Reset user password */
  @route("{id}/reset-password")
  @post
  resetPassword(@path id: string, @body body: ResetPasswordRequest): PasswordResetResponse | UserError;
}
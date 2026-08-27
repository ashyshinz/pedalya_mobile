import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static String? token;
  static Map<String, dynamic>? currentUser;

  static Future<Map<String, dynamic>> testConnection() async {
    final response = await http.get(
      Uri.parse('$baseUrl/test'),
      headers: {
        'Accept': 'application/json',
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  
  
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        'device_name': 'pedalya_mobile',
      }),
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
if (response.statusCode == 200) {
  token = data['token']?.toString();

  if (data['user'] is Map) {
    currentUser = Map<String, dynamic>.from(data['user']);
  }

  await getProfile();

  return {
    'success': true,
    'data': data,
  };
}

    String message = data['message']?.toString() ?? 'Login failed.';

    if (response.statusCode == 422 && data['errors'] is Map) {
      final errors = data['errors'] as Map;

      if (errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        }
      }
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message': message,
    };
  }


static Future<Map<String, dynamic>> register({
  required String name,
  required String email,
  required String phoneNumber,
  required String password,
  required String passwordConfirmation,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name.trim(),
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_name': 'pedalya_mobile',
    }),
  );

  final Map<String, dynamic> data =
      response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
if (response.statusCode == 201) {
  token = data['token']?.toString();

  if (data['user'] is Map) {
    currentUser = Map<String, dynamic>.from(data['user']);
  }

  await getProfile();

  return {
    'success': true,
    'data': data,
  };
}
  String message =
      data['message']?.toString() ?? 'Registration failed.';

  if (response.statusCode == 422 && data['errors'] is Map) {
    final errors = data['errors'] as Map;

    if (errors.isNotEmpty) {
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        message = firstError.first.toString();
      }
    }
  }

  return {
    'success': false,
    'statusCode': response.statusCode,
    'message': message,
  };
}

static Future<Map<String, dynamic>> uploadIdVerification(
  String filePath,
) async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
    };
  }

  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/id-verification'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'id_image',
        filePath,
      ),
    );

    final streamedResponse = await request.send();
    final responseBody =
        await streamedResponse.stream.bytesToString();

    final data = responseBody.isNotEmpty
        ? jsonDecode(responseBody) as Map<String, dynamic>
        : <String, dynamic>{};

    if (streamedResponse.statusCode == 200) {
      if (data['user'] is Map) {
        currentUser =
            Map<String, dynamic>.from(data['user']);
      }

      return {
        'success': true,
        'message':
            data['message']?.toString() ??
            'ID submitted for verification.',
        'verificationStatus':
            data['verification_status']?.toString() ??
            'pending',
        'user': currentUser,
      };
    }

    return {
      'success': false,
      'statusCode': streamedResponse.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to upload ID.',
    };
  } catch (e) {
    return {
      'success': false,
      'message':
          'Could not upload your ID. Please try again.',
    };
  }
}

static Future<Map<String, dynamic>> forgotPassword({
  required String email,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
      }),
    );

    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    final data = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            data['message']?.toString() ??
            'Password reset code sent successfully.',
      };
    }

    String message =
        data['message']?.toString() ??
        'Failed to send password reset code.';

    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;

      if (errors['email'] is List &&
          (errors['email'] as List).isNotEmpty) {
        message = (errors['email'] as List).first.toString();
      }
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message': message,
    };
  } catch (e) {
    return {
      'success': false,
      'message':
          'Could not connect to the server. Please try again.',
    };
  }
}

static Future<Map<String, dynamic>> resetPassword({
  required String email,
  required String code,
  required String password,
  required String passwordConfirmation,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'code': code.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    final data = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            data['message']?.toString() ??
            'Password reset successfully.',
      };
    }

    String message =
        data['message']?.toString() ??
        'Failed to reset password.';

    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;

      for (final key in [
        'email',
        'code',
        'password',
      ]) {
        if (errors[key] is List &&
            (errors[key] as List).isNotEmpty) {
          message =
              (errors[key] as List).first.toString();
          break;
        }
      }
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message': message,
    };
  } catch (e) {
    return {
      'success': false,
      'message':
          'Could not connect to the server. Please try again.',
    };
  }
}

static Future<Map<String, dynamic>> getProfile() async {
  if (token == null) {
    return {
      'success': false,
      'message': 'No authentication token.',
    };
  }

  final response = await http.get(
    Uri.parse('$baseUrl/auth/profile'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final Map<String, dynamic> data =
      response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

  if (response.statusCode == 200) {
    final profileData =
        data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;

    currentUser = Map<String, dynamic>.from(profileData);

    return {
      'success': true,
      'user': currentUser,
    };
  }

  return {
    'success': false,
    'statusCode': response.statusCode,
    'message': data['message']?.toString() ?? 'Failed to load profile.',
  };
}

static Future<Map<String, dynamic>> updateProfile({
  required String name,
  required String email,
  required String phoneNumber,
  String? address,
}) async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
    };
  }

///this is the edit profile function that will be used to update the user profile information. It sends a PUT request to the API with the updated user details and handles the response accordingly.
  final response = await http.put(
    Uri.parse('$baseUrl/auth/profile'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'name': name.trim(),
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim(),
      'address': address?.trim(),
    }),
  );

  final Map<String, dynamic> data =
      response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

  if (response.statusCode == 200) {
    if (data['user'] is Map) {
      currentUser = Map<String, dynamic>.from(data['user']);
    }

    return {
      'success': true,
      'message':
          data['message']?.toString() ?? 'Profile updated successfully.',
      'user': currentUser,
    };
  }

  String message =
      data['message']?.toString() ?? 'Failed to update profile.';

  if (response.statusCode == 422 && data['errors'] is Map) {
    final errors = data['errors'] as Map;

    if (errors.isNotEmpty) {
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        message = firstError.first.toString();
      }
    }
  }

  return {
    'success': false,
    'statusCode': response.statusCode,
    'message': message,
  };
}

static Future<Map<String, dynamic>> changePassword({
  required String currentPassword,
  required String newPassword,
  required String passwordConfirmation,
}) async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
    };
  }

  try {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            data['message']?.toString() ??
            'Password changed successfully.',
      };
    }

    String message =
        data['message']?.toString() ?? 'Failed to change password.';

    if (response.statusCode == 422 && data['errors'] is Map) {
      final errors = data['errors'] as Map;

      if (errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        }
      }
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message': message,
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Could not connect to Pedalya. Please try again.',
    };
  }
}  

static Future<Map<String, dynamic>> logout() async {
  if (token == null) {
    currentUser = null;

    return {
      'success': true,
      'message': 'Logged out successfully.',
    };
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

    if (response.statusCode == 200) {
      token = null;
      currentUser = null;

      return {
        'success': true,
        'message':
            data['message']?.toString() ??
            'Logged out successfully.',
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to log out.',
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Could not connect to Pedalya. Please try again.',
    };
  }
}

static Future<Map<String, dynamic>> getNotifications() async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
    };
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

    if (response.statusCode == 200) {
      final List<dynamic> notifications =
          data['data'] is List ? data['data'] as List<dynamic> : [];

      return {
        'success': true,
        'notifications': notifications,
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to load notifications.',
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Could not connect to Pedalya. Please try again.',
    };
  }
}

static Future<Map<String, dynamic>> getUnreadNotificationCount() async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
      'unreadCount': 0,
    };
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

    if (response.statusCode == 200) {
      return {
        'success': true,
        'unreadCount': data['unread_count'] ?? 0,
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to load unread notifications.',
      'unreadCount': 0,
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Could not connect to Pedalya. Please try again.',
      'unreadCount': 0,
    };
  }
}

static Future<Map<String, dynamic>> markNotificationRead(
  int notificationId,
) async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
    };
  }

  try {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            data['message']?.toString() ??
            'Notification marked as read.',
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to mark notification as read.',
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Could not connect to Pedalya. Please try again.',
    };
  }
}

static Future<Map<String, dynamic>> markAllNotificationsRead() async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
    };
  }

  try {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            data['message']?.toString() ??
            'All notifications marked as read.',
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to mark all notifications as read.',
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Could not connect to Pedalya. Please try again.',
    };
  }
}

static Future<Map<String, dynamic>> getActiveRentals() async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
      'rentals': <dynamic>[],
    };
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/rentals/active'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

    if (response.statusCode == 200) {
      final List<dynamic> rentals =
          data['data'] is List
              ? data['data'] as List<dynamic>
              : [];

      return {
        'success': true,
        'rentals': rentals,
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to load active rentals.',
      'rentals': <dynamic>[],
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Could not connect to Pedalya. Please try again.',
      'rentals': <dynamic>[],
    };
  }
}

static Future<Map<String, dynamic>> getCompletedRentals() async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
      'rentals': <dynamic>[],
    };
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/rentals?status=completed'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

    if (response.statusCode == 200) {
      final List<dynamic> rentals =
          data['data'] is List
              ? data['data'] as List<dynamic>
              : [];

      return {
        'success': true,
        'rentals': rentals,
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to load completed rentals.',
      'rentals': <dynamic>[],
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Could not connect to Pedalya. Please try again.',
      'rentals': <dynamic>[],
    };
  }
}

static Future<Map<String, dynamic>> returnRental(
  int rentalId, {
  double? returnLat,
  double? returnLng,
  String? paymentMethod,
  String? paymentReference,
  String? notes,
}) async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
    };
  }

  try {
    final response = await http.put(
      Uri.parse('$baseUrl/rentals/$rentalId/return'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'return_lat': returnLat,
        'return_lng': returnLng,
        'payment_method': paymentMethod,
        'payment_reference': paymentReference,
        'notes': notes,
      }),
    );

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            data['message']?.toString() ??
            'Bicycle returned successfully.',
        'rental': data['rental'],
        'fees': data['fees'],
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to return bicycle.',
    };
  } catch (e) {
    return {
      'success': false,
      'message':
          'Could not connect to Pedalya. Please try again.',
    };
  }
}

static Future<Map<String, dynamic>>
    getAvailableBicycles() async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
      'bicycles': <dynamic>[],
    };
  }

  try {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/bicycles?status=available&per_page=100',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final List<dynamic> bicycles =
          data['data'] is List
              ? data['data'] as List<dynamic>
              : <dynamic>[];

      return {
        'success': true,
        'bicycles': bicycles,
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to load available bicycles.',
      'bicycles': <dynamic>[],
    };
  } catch (e) {
    return {
      'success': false,
      'message':
          'Could not connect to Pedalya. Please try again.',
      'bicycles': <dynamic>[],
    };
  }
}
static Future<Map<String, dynamic>> startRental(
  int bicycleId,
  int durationMinutes,
) async {
  if (token == null) {
    return {
      'success': false,
      'message': 'You are not logged in.',
    };
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'bicycle_id': bicycleId,
        'duration_minutes': durationMinutes,
      }),
    );

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return {
        'success': true,
        'message':
            data['message']?.toString() ??
            'Rental started successfully.',
        'rental': data['rental'],
      };
    }

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message':
          data['message']?.toString() ??
          'Failed to start rental.',
    };
  } catch (e) {
    return {
      'success': false,
      'message':
          'Could not connect to Pedalya. Please try again.',
    };
  }
}


}
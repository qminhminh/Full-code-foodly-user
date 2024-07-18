// ignore_for_file: file_names

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:foodly_user/models/environment.dart';
import 'package:foodly_user/models/foods.dart';
import 'package:foodly_user/models/hook_models/hook_result.dart';
import 'package:http/http.dart' as http;

// Custom Hook
FetchHook useFetchMenu(id) {
  final foods = useState<List<Food>?>(null);
  final isLoading = useState(false);
  final error = useState<Exception?>(null);

  // Fetch Data Function
  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(
          '${Environment.appBaseUrl}/api/foods/restaurant-foods/$id'));

      if (response.statusCode == 200) {
        foods.value = foodFromJson(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e.toString());
      // error.value = e as Exception?;
    } finally {
      isLoading.value = false;
    }
  }

  // Side Effect
  useEffect(() {
    fetchData();
    return null;
  }, const []);

  // Refetch Function
  void refetch() {
    isLoading.value = true;
    fetchData();
  }

  // Return values
  return FetchHook(
    data: foods.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}

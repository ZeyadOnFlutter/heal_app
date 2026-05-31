class HealthDataModel {
  double bmi = 25.0;
  int highBP = 0;
  int highChol = 0;
  int cholCheck = 1;
  int smoker = 0;
  int physActivity = 1;
  int fruits = 1;
  int veggies = 1;
  int hvyAlcoholConsump = 0;
  int anyHealthcare = 1;
  int noDocbcCost = 0;
  int genHlth = 3;
  int mentHlth = 0;
  int physHlth = 0;
  int diffWalk = 0;
  int sex = 0;
  int age = 7;
  int education = 4;
  int income = 5;

  Map<String, dynamic> toJson() {
    return {
      'GenHlth': genHlth,
      'BMI': bmi.round(),
      'HighBP': highBP,
      'Age': age,
      'HighChol': highChol,
      'PhysHlth': physHlth,
      'DiffWalk': diffWalk,
      'PhysActivity': physActivity,
    };
  }

  static HealthDataModel fromJson(Map<String, dynamic> json) {
    final m = HealthDataModel();
    m.bmi = (json['BMI'] ?? 25.0).toDouble();
    m.highBP = json['HighBP'] ?? 0;
    m.highChol = json['HighChol'] ?? 0;
    m.cholCheck = json['CholCheck'] ?? 1;
    m.smoker = json['Smoker'] ?? 0;
    m.physActivity = json['PhysActivity'] ?? 1;
    m.fruits = json['Fruits'] ?? 1;
    m.veggies = json['Veggies'] ?? 1;
    m.hvyAlcoholConsump = json['HvyAlcoholConsump'] ?? 0;
    m.anyHealthcare = json['AnyHealthcare'] ?? 1;
    m.noDocbcCost = json['NoDocbcCost'] ?? 0;
    m.genHlth = json['GenHlth'] ?? 3;
    m.mentHlth = json['MentHlth'] ?? 0;
    m.physHlth = json['PhysHlth'] ?? 0;
    m.diffWalk = json['DiffWalk'] ?? 0;
    m.sex = json['Sex'] ?? 0;
    m.age = json['Age'] ?? 7;
    m.education = json['Education'] ?? 4;
    m.income = json['Income'] ?? 5;
    return m;
  }
}

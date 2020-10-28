import 'dart:io';
import 'dart:convert';

class Deployment {
  String environment;
  String created_string;
  DateTime created_datetime;
  String state;
  String name;

  Deployment(this.environment, this.created_string, this.state, this.name) {
    this.created_datetime = DateTime.parse(created_string);
  }

  factory Deployment.fromJson(dynamic json) {
    return Deployment(
        json['environment'], json['created'], json['state'], json['name']);
  }

  String toString() {
    return '\nDeployment(${this.environment}, ${this.created_string}, ${this.state}, ${this.name})';
  }
}

class Release {
  String version;
  List<Deployment> deployments;

  Release(this.version, this.deployments);

  factory Release.fromJson(dynamic json) {
    var deploymentsList = json['deployments'];
    var deployments = deploymentsList != null
        ? deploymentsList
            .map<Deployment>((deployment) => Deployment.fromJson(deployment))
            .toList()
        : null;
    return Release(json['version'] as String, deployments);
  }

  String toString() {
    return '\nRelease(${this.version}, ${this.deployments})';
  }
}

class Environment {
  String environment;

  Environment(this.environment);

  factory Environment.fromJson(dynamic json) {
    return Environment(json['environment'] as String);
  }

  String toString() {
    return '\nEnvironment(${this.environment})';
  }
}

class Project {
  String project_id;
  String project_group;
  List<Environment> environments;
  List<Release> releases;

  Project(
      this.project_id, this.project_group, this.environments, this.releases);

  factory Project.fromJson(dynamic json) {
    // Environments
    var environmentsList = json['environments'];
    var environments = environmentsList != null
        ? environmentsList
            .map<Environment>((env) => Environment.fromJson(env))
            .toList()
        : null;
    // Releases
    var releasesList = json['releases'];
    var releases = releasesList != null
        ? releasesList
            .map<Release>((release) => Release.fromJson(release))
            .toList()
        : null;

    return Project(json['project_id'] as String,
        json['project_group'] as String, environments, releases);
  }

  String toString() {
    return '\nProject(${this.project_id}, ${this.project_group}, ${this.environments}, ${this.releases})';
  }
}

void main() {
  print("Reading data...");

  var assessmentData = File('projects.json').readAsStringSync();

  var projectsList = jsonDecode(assessmentData)['projects'] as List;
  List<Project> projects = projectsList != null
      ? projectsList
          .map<Project>((project) => Project.fromJson(project))
          .toList()
      : null;

  // We have parsed the data
  print('Successfully loaded data for ${projects.length} projects.');

  //
  // Solutions to assessment questions
  //

  //
  // 1. Day of week deployment frequency (for live deployments)
  //

  var days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  var dailyDeployments = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

  for (var project in projects) {
    for (var release in project.releases) {
      for (var deployment in release.deployments) {
        if (deployment.environment == 'Live') {
          dailyDeployments.update(
              deployment.created_datetime.weekday, (value) => value + 1);
        }
      }
    }
  }

  print('\n1. Deployments to Live by Day');
  for (var i = 0; i < days.length; i++) {
    print('${days[i]}: ${dailyDeployments[i + 1]}');
  }
  print('-----\n');

  //
  // 2. Projects with slow releases (from Int to Live)
  //

  Map<String, Map<String, int>> groupStatsMap;
  groupStatsMap = {};

  for (var project in projects) {
    var group = project.project_group;
    for (var release in project.releases) {
      /* 
        Note:
        From examining the data it becomes clear that each release can have
        a deployment to Integration after the (final?) deployment to Live,
        presumably for debugging purposes. So the best approach is to reverse
        the list in place, then choose the first Live deployment and then
        the next Integration deployment from the modified list.
      */
      var mostRecentDeployments = release.deployments.reversed;

      // Live deployment time
      var mostRecentLiveDeployments =
          mostRecentDeployments.where((d) => d.environment == 'Live');
      if (mostRecentLiveDeployments.isEmpty) continue;
      var deployLiveTime = mostRecentLiveDeployments.first.created_datetime;

      // Integration deployment time
      var mostRecentIntDeployments = mostRecentDeployments =
          mostRecentDeployments.where((d) =>
              d.environment == 'Integration' &&
              d.created_datetime.isBefore(deployLiveTime));
      if (mostRecentIntDeployments.isEmpty) continue;
      var deployIntTime = mostRecentIntDeployments.first.created_datetime;

      // Ensure project group is a key in our counters
      groupStatsMap.putIfAbsent(
          group, () => {'Releases': 0, 'Minutes': 0, 'AverageMinutes': 0});

      // Update our counter structure
      groupStatsMap[group].update('Releases', (r) => r + 1);
      groupStatsMap[group].update('Minutes', (m) {
        var diff = deployLiveTime.difference(deployIntTime).inMinutes;
        return m + diff;
      });
    }
  }

  // Calculate average times and store relevant info in a list
  // ready for the sorting step below. (Maps cannot be reordered)
  var groupStatsList = [];
  for (var group in groupStatsMap.keys) {
    var average =
        groupStatsMap[group]['Minutes'] / groupStatsMap[group]['Releases'];
    var averageInt =
        average.round(); // Because the requirements show whole numbers
    groupStatsMap[group]['AverageMinutes'] = averageInt;
    groupStatsList.add({'Group': group, 'AverageMinutes': averageInt});
  }

  // Reorder by longest average minutes
  groupStatsList
      .sort((e1, e2) => e2['AverageMinutes'].compareTo(e1['AverageMinutes']));

  print('\n2. Average Release Times in Minutes');
  for (var g in groupStatsList) {
    print('${g['Group']}: ${g['AverageMinutes']}');
  }
  print('-----\n');

// 3. Failing releases

// HINTS

// projects.where(lambda condition).forEach()
}

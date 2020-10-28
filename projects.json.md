
# Deployment data

NHS Digital has invested in some automated deployment tooling which has recorded its deployment history.

The data is made up of a number of projects, a more detailed description is shown below.

```
Each project has a:

  project_id: A unique GUID

  project_group: A parent project group name of which the project is a member

  environments: A list of deployment environments that the project is deployed to, for example:
		    Integration
		    Regression
		    QA
		    UAT
		    Live

  releases: one or more release. Each release details:

    version: a unique version identifier

    deployments: one or more deployments associated with a particular release.  Each deployment details:

      environment: the environment the release was deployed to

      created: a timestamp when the deployment took place

      state: whether the deployment was successful

      name: the name of the deployment
```

Please note:

- Versions are ordered from earliest to latest
- Deployments are ordered from earliest to latest


## Example


```
{
  "projects": [
  {
      "project_id": "9f564a48-e40c-11e9-bc4f-acb57d6c5605",
      "project_group": "Spaniel",
      "environments": [
        {
          "environment": "Integration"
        },
        {
          "environment": "Test"
        },
        {
          "environment": "Live"
        }
      ],
      "releases": [
        {
          "version": "1.1.1.001",
          "deployments": [
            {
              "environment": "Integration",
              "created": "2019-10-01T06:40:01.000Z",
              "state": "Success",
              "name": "Deploy to Integration"
            },
            {
              "environment": "Test",
              "created": "2019-10-01T08:23:58.000Z",
              "state": "Success",
              "name": "Deploy to Test"
            },
            {
              "environment": "Live",
              "created": "2019-10-01T09:02:17.000Z",
              "state": "Success",
              "name": "Deploy to Live"
            }
          ]
        }
      ]
    }
  ]
}
```


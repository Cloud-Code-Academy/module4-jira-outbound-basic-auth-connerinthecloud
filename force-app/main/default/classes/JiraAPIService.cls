/**
 * Service class for making callouts to the Jira API
 */
public with sharing class JiraAPIService {

	private static final String JIRA_NAMED_CREDENTIAL = 'callout:Jira';
	private static final String JIRA_PROJECT_URL = '/project';
	private static final String JIRA_ISSUE_URL = '/issue';


	/**
	 * Creates a project in Jira
	 * @param projectWrapper The project wrapper object containing all necessary data
	 * @return String The Jira project ID
	 *
	 * TODO: Implement this method to make a callout to Jira API to create a project
	 * Reminder: Extract and return the project ID from the response
	 */
	public static String createProject(JiraWrapper.ProjectWrapper projectWrapper) {
		// build the project request body
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('key', projectWrapper.key);
		requestBody.put('name', projectWrapper.name);
		requestBody.put('projectTemplateKey', projectWrapper.projectTemplateKey);
		requestBody.put('leadAccountId', projectWrapper.leadAccountId);
		requestBody.put('description', projectWrapper.description);
		
		Map<String, Object> responseMap = doJiraCallout('POST', JIRA_PROJECT_URL, requestBody);
		String projectId = String.valueOf(responseMap.get('id'));

		return String.isBlank(projectId) ? null : projectId;
	}

	/**
	 * Creates an issue in Jira
	 * @param issueWrapper The issue wrapper object containing all necessary data
	 * @return String The Jira issue key
	 *
	 * TODO: Implement this method to make a callout to Jira API to create an issue
	 * Reminder: Extract and return the issue key from the response
	 */
	public static String createIssue(JiraWrapper.IssueWrapper issueWrapper) {
		// Build the issue request body
		Map<String, Object> requestBody = issueWrapper.generateIssuePayloadMap();
		Map<String, Object> responseMap = doJiraCallout('POST', JIRA_ISSUE_URL, requestBody);
		String issueKey = String.valueOf(responseMap.get('key'));
		
		return String.isBlank(issueKey) ? null : issueKey;
	}

	/**
	 * Helper method for callouts
	 * 
	 * @param method the HTTP request method
	 * @param calloutType project or issue type
	 * @param requestBody body of the http request
	 * @return HttpResponse the response received from the callout
	 */
	private static Map<String, Object> doJiraCallout(String method, String calloutType, Map<String, Object> requestBody) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod(method);
		request.setEndpoint(JIRA_NAMED_CREDENTIAL + calloutType);
		request.setHeader('Content-Type', 'application/json');
		request.setBody(JSON.serialize(requestBody));

		Map<String, Object> responseMap = new Map<String, Object>();
		try {
			HttpResponse response = http.send(request);
			if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
				responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			} else {
				String errorMessage = 'Invalid response from Jira callout. ';
				Logger.error(errorMessage + 'Status code: ' + response.getStatusCode());
			}
		} catch (CalloutException e) {
			String errorMessage = 'Jira callout error. ';
			Logger.error(errorMessage + e.getMessage());
			Logger.saveLog();
		}

		return responseMap;
	}

	/**
	 * Custom Exception class for the JiraAPI
	 */
	public class JiraAPIException extends Exception {}
}

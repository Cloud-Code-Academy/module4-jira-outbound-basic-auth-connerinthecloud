/**
 * Wrapper classes for Jira entities (Project and Issue)
 */
public class JiraWrapper {
	private static final String LEAD_ACCOUNT_ID =  Jira_Project_Settings__mdt.getInstance('Jira_Data').Lead_Account_Id__c;
	private static final String PROJECT_TEMPLATE_KEY = Jira_Project_Settings__mdt.getInstance('Jira_Data').Project_Template_Key__c;

	/**
	 * Wrapper for Jira Project
	 */
	public class ProjectWrapper {
		public String name;
		public String key;
		public String description;
		public String leadAccountId;
		public String projectTemplateKey;

		/**
		 * Constructor for ProjectWrapper
		 */
		public ProjectWrapper(String name, String key, String description) {
			this.name = name;
			this.key = key;
			this.description = description;
			this.leadAccountId = LEAD_ACCOUNT_ID;
			this.projectTemplateKey = PROJECT_TEMPLATE_KEY;
		}
	}

	/**
	 * Wrapper for Jira Issue
	 */
	public class IssueWrapper {
		public String name;
		public String key;
		public String description;
		public String projectKey;
		public String summary;
		public String issueType;

		/**
		 * Constructor for IssueWrapper
		 */
		public IssueWrapper(
			String projectKey,
			String summary,
			String description,
			String issueType
		) {
			this.projectKey = projectKey;
			this.summary = summary;
			this.description = description;
			this.issueType = (String.isNotBlank(issueType)) ? issueType : 'Task';
		}

		/**
		 * Convert IssueWrapper to a Map for serialization
		 *
		 * TODO: Implement this method to create a Map that represents
		 * the JSON payload needed for the Jira API. The Map should contain:
		 * - fields object with project information (key)
		 * - issuetype object with the issue type name
		 * - summary field
		 * - description field (formatted using formatDescription method)
		 * - Example:
		 */
		public Map<String, Object> generateIssuePayloadMap() {

			Map<String, String> issueTypeMap = new Map<String, String>();
			Map<String, String> projectMap = new Map<String, String>();
			projectMap.put('key', this.projectKey);

			Map<String, Object> fieldMap = new Map<String, Object>();
			fieldMap.put('project', projectMap);
			fieldMap.put('summary', this.summary);
			fieldMap.put('description', formatDescription(this.description));
			fieldMap.put('issuetype', issueTypeMap);

			Map<String, Object> issuePayload = new Map<String, Object>();
			issuePayload.put('fields', fieldMap);

			return issuePayload;
		}

		/**
		 * Format description as per Jira Cloud API requirements
		 *
		 * TODO: Implement this method to format the description text
		 * according to Jira Cloud API requirements.
		 * - Create a Map with type="doc" and version=1
		 * - Add content array with paragraph object
		 * - Add text object inside paragraph content with the description
		 * - Example:
		 *   {
		 *     "description": {
		 *       "type": "doc",
		 *       "version": 1,
		 *       "content": [ 
		 *         {
		 *           "type": "paragraph",
		 *           "content": [ 
		 *             {
		 *               "type": "text",
		 *               "text": "Order entry fails when selecting supplier."
		 *             }
		 *           ]
		 *         }
		 *       ]
		 *     }
		 *   }
		 */
		private Map<String, Object> formatDescription(String descText) {
			// Your implementation goes here
			List<Map<String, String>> textContentList = new List<Map<String,String>>();
			Map<String, String> textContentMap = new Map<String, String>();
			textContentMap.put('type', 'text');
			textContentMap.put('text', descText);
			textContentList.add(textContentMap);

			List<Map<String, Object>> contentList = new List<Map<String, Object>>();
			Map<String, Object> paragraphMap = new Map<String,Object>();
			paragraphMap.put('type', 'paragraph');
			paragraphMap.put('content', textContentList);
			contentList.add(paragraphMap);

			Map<String, Object> descriptionMap = new Map<String, Object>();
			descriptionMap.put('type', 'doc');
			descriptionMap.put('version', 1);
			descriptionMap.put('content', contentList);

			return descriptionMap;
		}
	}
}

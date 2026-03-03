/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Thayne Rodrigo
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account acc = new Account();
        // Set some fields on the Account
        acc.Name = randomAccountName();
        acc.Type = 'Prospect';
        acc.BillingCity = 'Australia';
        // Insert the Account into the database
        insert acc;
        // Return the Id of the newly created Account
        return acc.Id;
    }
    // TR - Generates random name. I know this isn't really robust, but for this use case, I hope it's ok.
     public static String randomAccountName(){ 
        Integer randomNumber = (Integer)(math.random() * 100);
        Integer secondRandomNumber = (Integer)(math.random() * (100 - 50 + 1) + 50);
        String randomName = 'Account ' + randomNumber.toString() + secondRandomNumber.toString();
        return randomName;
     }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline    
        Account acc = new Account(Name = name, Industry = industry);
        // Insert the Account
        insert acc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact contact = new Contact();
        // Set some fields on the Contact
        contact.FirstName = 'Thayne';
        contact.LastName = 'Rodrigo';
        contact.Languages__c = 'English';
        // Set the AccountId field to the given accountId
        contact.AccountId = accountId;
        // Insert the Contact into the database
        insert contact;
        // Return the Id of the newly created Contact
        return contact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        List<Contact> getContact = [SELECT Id FROM Contact WHERE Id = :contactId]; // retrieve
        // Update the Contact's last name
        Contact cont = getContact[0];
        // Update the Contact in the database
        cont.LastName = newLastName;
        update cont;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        List <Opportunity> getOpportunity = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        Opportunity opp = getOpportunity[0];
        opp.StageName = newStage;
        // Update the Opportunity in the database
        update opp;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     * 
     * // TR - Because we're only querying for a single record, I wanted to try and directly set the instance to the SOQL statement. This does assume that we won't hit errors from a 
     // duplicate/matching rule and that there is truly one unique record to retrieve and after update.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {

        Account acc = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
        acc.Name = newName;
        acc.Industry = newIndustry;
        update acc;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;
        }
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names. //create opportunity
     * Associate the Opportunities with account that has the name accountName. // relate opportunity to account
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     * 
     * TR - Hey teach, I wasn't sure what the second hint actually means. Does it mean no duplicate opportunities by name related to accounts? E.g -
     * Account A => Opportunity 1, Opportunity 2, Opportunity 3 && Account B => Opportunity 1, Opportunity 2, Opportunity 3?
     * 
     * I made the conclusion that we're just talking about there being no duplicate opportunities at all, which is why I kept my code simple. The upsert
     * should avoid creating duplicates based off the name.
     * 
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
     Account acc = new Account(Name = accountName); 
     insert acc;

    List<Opportunity> opportunities = new List<Opportunity>();
        for (String oppName : oppNames)
        {   
            Opportunity opp = new Opportunity(); 
            opp.AccountId = acc.Id; 
            opp.Name = oppName; 
            opportunities.add(opp); 
        } 
        upsertOpportunityList(opportunities); //call method to create new opportunities in list.
        } 

    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        Account acc = new Account();
		
        if (accounts.isEmpty()) { 
            acc.Name = accountName;
            acc.Description = 'New Account';
            
        } else { 
            acc = accounts.get(0);
            acc.Description = 'Updated Account';
        }
            upsert acc;
            return acc;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {

        List<Contact> contacts = new List<Contact>();

		// Loop through each Contact
        for (Contact contact : contactsToUpsert) { 
            Contact cont = new Contact();
            // Extract the Account Name from Contact's LastName
            String accountName = contact.LastName; 
            // Get the account based on the name or create one if it doesn't exist
            Account acc = upsertAccount(accountName); 
            // Link the Contact to its Account using the Account Id
            cont.AccountId = acc.Id;
            cont.LastName = contact.LastName;
            cont.FirstName = contact.FirstName;
            // TR - add to list to upsert contactsToUpsert
            contacts.add(cont);
        }
        // Upsert the Contacts
		upsert contacts;

		
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {

        List <Lead> leadInsertDelete = new List<Lead>();
        // Loop through each Lead name
        for (String leadName : leadNames) {
        Lead lead = new Lead ();
        lead.LastName = leadName;
        lead.Company = 'Log Horizon';
        leadInsertDelete.add(lead);
        }
        // Insert the Leads
        insert leadInsertDelete;

        // Delete the Leads
        delete leadInsertDelete;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {

        List<Case> caseInsert = new List<Case>();

        for (Integer i = 0; i < numOfCases; i++) {
            Case currentCase = new Case();
            currentCase.Subject = 'Case number: ' + i;
            currentCase.Origin = 'Web';
            currentCase.AccountId = accountId;
            caseInsert.add(currentCase);
        }
        // Insert the cases
        insert caseInsert;

        // Delete the cases
        delete caseInsert;
    }
}
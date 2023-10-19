@isTest
private class Problem00001Test {
	private static List<String> names=new List<String>{
		'Elon Musk',
		'Mark Zuckerberg',
		'Dwayne Johnson',
		'Bill Gates',
		'Elon Musk',
		'Bill Gates',
		'Warren Buffett',
		'Jeff Bezos'
	};

    @TestSetup
    static void createTestData() {
		List<Contact> newContacts = new List<Contact>();
		List<Account> newAccounts = new List<Account>();
		newAccounts.add(TestDataFactory.createAccount(false,1));
		newAccounts.add(TestDataFactory.createAccount(false,2));
		insert newAccounts;

		String[] nameSplit=new String[2];
		Contact loopContact;
		for(Integer i=0; i<names.size(); i++){
			nameSplit=names[i].split(' ');
			loopContact=new Contact(
				FirstName=nameSplit[0],
				LastName=nameSplit[1]
			);

			newContacts.add(TestDataFactory.createContact(
				false,
				newAccounts[i<names.size()/2? 0:1].Id,
				loopContact
			));
		}
		insert newContacts;
    } 

	@isTest
    static void testInsert() {
		List<Contact> contactsInserted=[SELECT Name, AccountId, Account.Name FROM Contact];
		Map<Id,List<String>> accListNames = new Map<Id,List<String>>();
		Map<Id,Set<String>> accSetNames = new Map<Id,Set<String>>();

		for(Contact con:contactsInserted){
			if(!accListNames.containsKey(con.AccountId)){
				accListNames.put(con.AccountId, new List<String>());
			}
			accListNames.get(con.AccountId).add(con.Name);

			if(!accSetNames.containsKey(con.AccountId)){
				accSetNames.put(con.AccountId, new Set<String>());
			}
			accSetNames.get(con.AccountId).add(con.Name);
		}

		List<Account> parentAccounts;
		if(Problem00001.testThisCode){
			parentAccounts=Problem00001.updateAccountFieldWithContactNamesInsert(contactsInserted);
		}else{
			parentAccounts=solutionInsert(contactsInserted);
		}
		Assert.isNotNull(parentAccounts,'return value is null');
		update parentAccounts;
		
		parentAccounts=[SELECT Name, ContactChildNames__c,(SELECT Name FROM Contacts) FROM Account];

		for(Account parentAccount:parentAccounts){
			List<String> namesList = parentAccount.ContactChildNames__c.split(';');
			Set<String> namesSet = new Set<String>(namesList);

			if(namesList.size() != accListNames.get(parentAccount.Id).size()){
				System.debug('Mismatch for Account: '+parentAccount.Name);
				System.debug('initialNames:'+namesList);
				System.debug('finalNames:'+accListNames.get(parentAccount.Id));
				Assert.isTrue(false);
			}
			if(!namesSet.containsAll(accSetNames.get(parentAccount.Id))){
				System.debug('Mismatch contact initialNames and finalNames.');
				System.debug('initialNames:'+namesSet);
				System.debug('finalNames:'+accSetNames.get(parentAccount.Id));
				Assert.isTrue(false);
			}
		}
    } 
	@isTest
    static void testUpdate() {
		List<Contact> contactsInserted=[SELECT Name, AccountId FROM Contact];
		List<Contact> listA = new List<Contact>();
		List<Contact> updatedContacts = new List<Contact>();
		Map<Id,Contact> oldContacts = new Map<Id,Contact>();
		Set<String> newNames = new Set<String>();
		Set<String> contactNames = new Set<String>();
		for(Integer i=0; i<contactsInserted.size(); i++){
			if(i<Math.round(contactsInserted.size()/2)){
				listA.add(contactsInserted[i]);
			}else{
				oldContacts.put(contactsInserted[i].Id, contactsInserted[i]);
				contactsInserted[i].FirstName = contactsInserted[i].Name.split(' ')[0] + 'zzz';
				newNames.add(contactsInserted[i].FirstName);
				updatedContacts.add(contactsInserted[i]);
			}
		}

		List<Account> parentAccounts=solutionInsert(listA);
		update parentAccounts;

		if(Problem00001.testThisCode){
			parentAccounts=Problem00001.updateAccountFieldWithContactNamesUpdate(updatedContacts,oldContacts);
		}else{
			// parentAccounts=solutionUpdate(updatedContacts,oldContacts);
			return;
		}
		Assert.isNotNull(parentAccounts,'return value is null');
		update parentAccounts;

		parentAccounts=[SELECT ContactChildNames__c,(SELECT Name FROM Contacts) FROM Account];

		for(Account parentAccount:parentAccounts){
			Map<String,Integer> contactRecordNameMap = getNameCounterMap(parentAccount.contacts);
			Map<String,Integer> accountFieldNameMap = getNameCounterMap(parentAccount.ContactChildNames__c);

			if(contactRecordNameMap.size() != accountFieldNameMap.size()){
				System.debug('Different unique names: Contact Childs: '+contactRecordNameMap.size()+', Account Count Field: '+accountFieldNameMap.size());
				Assert.isTrue(false);
			}

			for(String name:contactRecordNameMap.keySet()){
				contactNames.add(name);
				if(contactRecordNameMap.get(name) != accountFieldNameMap.get(name)){
					System.debug('Different name count for "'+name+'": Contact Childs: '+contactRecordNameMap.get(name)+', Account Count Field: '+accountFieldNameMap.get(name));
					Assert.isTrue(false);
				}
			}
		}

		if(!contactNames.containsAll(newNames)){
			System.debug('All or some new contact names were updated when only having to make updates to Account.');
			System.debug('contactNames:'+contactNames);
			System.debug('newNames:'+newNames);
			Assert.isTrue(false);
		}
    } 


	//Utility methods
	private static Map<String,Integer> getNameCounterMap(List<Contact> contacts){
		List<String> namesList=new List<String>();
		
		for(Contact childContact:contacts){
			namesList.add(childContact.Name);
		}

		return getNameCounterMap(namesList);
	}
	private static Map<String,Integer> getNameCounterMap(String names){
		List<String> namesList;
		if(String.isNotBlank(names)&&names.contains(';')){
			namesList = names.split(';');
		}else{
			namesList = new List<String>();
		}

		return getNameCounterMap(namesList);
	}
	private static Map<String,Integer> getNameCounterMap(List<String> namesList){

		Map<String,Integer> nameCounterMap=new Map<String,Integer>();
		for(String name:namesList){
			if(!nameCounterMap.containsKey(name)){
				nameCounterMap.put(name, 1);
			}else{
				nameCounterMap.put(name, nameCounterMap.get(name) + 1);
			}
		}

		return nameCounterMap;
	}

	// Solutions
	public static List<Account> solutionInsert(List<Contact> newContacts){
        Set<Id> parentAccountIds=new Set<Id>();
		for(Contact loopContact:newContacts){
			parentAccountIds.add(loopContact.AccountId);
		}
        List<Account> parentAccount = [
            SELECT ContactChildNames__c
            FROM Account
            WHERE Id IN: parentAccountIds
        ];

        Map<Id,List<String>> accountIdWithChildContactNames = new Map<Id,List<String>>();
        for(Contact loopContact:newContacts){
            if(!accountIdWithChildContactNames.containsKey(loopContact.AccountId)){
                accountIdWithChildContactNames.put(loopContact.AccountId, new List<String>());
            }
            accountIdWithChildContactNames.get(loopContact.AccountId).add(loopContact.Name);
        }

        for(Account loopAccount:parentAccount){
            List<String> namesList=new List<String>();
            if(String.isNotBlank(loopAccount.ContactChildNames__c)){
                namesList.addAll(loopAccount.ContactChildNames__c.split(';'));
            }
            if(accountIdWithChildContactNames.containsKey(loopAccount.Id)){
                namesList.addAll(accountIdWithChildContactNames.get(loopAccount.Id));
            }
            loopAccount.ContactChildNames__c=String.join(namesList, ';');
        }

        return parentAccount;
    }
}
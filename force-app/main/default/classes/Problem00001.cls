/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Account field ContactChildNames__c should contain all child Contact names seperated by semicolon.
*
    Example

    Contact(AccountId = '0001', Name = 'Pepe Garcia')
    Contact(AccountId = '0001', Name = 'Juan Gomez')
    Contact(AccountId = '0001', Name = 'Maria Ramirez')

    Account(Id = '0001', ContactChildNames__c = 'Pepe Garcia;Juan Gomez;Maria Ramirez')

* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @difficulty               Mid,High
* @mainSubjects             Triggers, Apex, Maps, MasterDetail, StandardObjects
* @testMethods              Problem00001Test.testInsert, Problem00001Test.testUpdate
*/
public class Problem00001{

    @TestVisible private static Boolean testThisCode = false;
    public static List<Account> updateAccountFieldWithContactNamesInsert(List<Contact> newContacts){
        return null;
    }
    public static List<Account> updateAccountFieldWithContactNamesUpdate(List<Contact> newContacts,Map<Id,Contact> oldContacts){
        return null;
    }
}
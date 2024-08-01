public class OAuthExample2 {
    @AuraEnabled
    public static List<Object> getAccessToken2(String input) {
        String endpoint = 'https://login.salesforce.com/services/oauth2/token';
        String clientId = '3MVG9H_KVs6V9LiP.vS5LDnOR13E4Z2QskHKiJKPqu6dg5q88foj_gHq1kWEQXv97VHT6b6VcM_RzRftnPm67';
        String clientSecret = 'A8C9045442442F6F8D485095FE0BB6EDDB8EAFF03CAA56AAC5CA68D90408A4A0';
        String username = 'deekshithgowda978@gmail.com2024/07/25_16-35-7.demo';
        String password = 'Kasetti@555';
        String grantType = 'password';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String body = 'grant_type=' + EncodingUtil.urlEncode(grantType, 'UTF-8') +
            '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
            '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(password, 'UTF-8');
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            String responseBody = res.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            String accessToken = (String) responseMap.get('access_token');
            List<Object> data=new  List<Object>();
            Map<String,Object> dataObj=(Map<String,Object>)DataCloudOauth2.getAccessToken2(accessToken, input);
            List<Object> medication=(List<Object>)dataObj.get('data2');
            List<Object> practitioner=(List<Object>)dataObj.get('data3');
            List<Object> medrequest=(List<Object>)dataObj.get('data4');
            String patientName=(String)dataObj.get('patName');
            System.debug('patientName--------> '+patientName);
            Map<String,Object> mdb=new Map<String,Object>{'name'=>patientName,'medication'=>medication, 'practitioner'=>practitioner, 'medrequest'=>medrequest};
            data.add(mdb);
            List<Object> finalData=(List<Object>)getFinalDataForUi(dataObj);
            System.debug('finalDataBDBD=>'+finalData);
            return finalData;
            // return data;
        } else {
            System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
            System.debug('Error Body: ' + res.getBody());
            return null;
        }
    }
    public static List<Object> getFinalDataForUi(Map<String,Object> data){
        String patientName=(String)data.get('patName');
        List<Object> medObjLst=(List<Object>)data.get('data2');
        List<Object> practObjLst=(List<Object>)data.get('data3');
        List<Object> medReqObjLst=(List<Object>)data.get('data4');
        List<Object> finalList=new List<Object>();
        Map<String,Object> patientMap=new Map<String,Object>();
        patientMap.put('patientName',patientName);
        List<Object> medReqLst=new List<Object>();
        for(Object medReqObj:medReqObjLst){
            Map<String,Object> mr=(Map<String,Object>)medReqObj;
            Map<String,Object> medReq=new Map<String,Object>();
            String medReqObjId=(String)mr.get('id__c');
            medReq.put('id',mr.get('id__c'));
            medReq.put('category',mr.get('category__c'));
            medReq.put('courseOfTherapyType',mr.get('courseOfTherapyType__c'));
            medReq.put('identifier',mr.get('identifier__c'));
            medReq.put('status',mr.get('status__c'));
            // Practitioner
            List<Object> practLst=new List<Object>();
            for(Object pracObj:practObjLst){
                Map<String,Object> pr=(Map<String,Object>)pracObj;
                String mrId=(String)pr.get('Epic_MedicationRequestId__c');
                if(mrId==medReqObjId){
                    Map<String,Object> practMap=new Map<String,Object>();
                    practMap.put('Practitioner_Id',pr.get('Practitioner_Id__c'));
                    practMap.put('display',pr.get('display__c'));
                    practMap.put('Practitioner_Type',pr.get('Practitioner_Type__c'));
                    practLst.add(practMap);
                }
            }
            medReq.put('practioners',practLst);
            // Medication
            List<Object> medLst=new List<Object>();
            for(Object medObj:medObjLst){
                Map<String,Object> md=(Map<String,Object>)medObj;
                String mdId=(String)md.get('Epic_MedicationRequesId__c');
                if(mdId==medReqObjId){
                    Map<String,Object> medMap=new Map<String,Object>();
                    medMap.put('Medication_Id',md.get('Medication_Id__c'));
                    medMap.put('id',md.get('id__c'));
                    medMap.put('display',md.get('display__c'));
                    medLst.add(medMap);
                }
            }
            medReq.put('medications',medLst);
            medReqLst.add(medReq);
        }
        patientMap.put('medicationRequest',medReqLst);
        finalList.add(patientMap);
        // System.debug('finalList=>'+finalList);
        return finalList;
    }
}
/*
Medication Request
    ==================
{
    "category__c": "Community",
    "courseOfTherapyType__c": "Short course (acute) therapy",
    "id__c": "eAV.5YjW2fTOYmNIzSUZuzw3", -----------------------------------------------MedicationRequestID
        "identifier__c": "795523",
    "intent__c": "order",
    "PatientId__c": "e63wRTbPfr1p8UW81d8Seiw3",
    "status__c": "stopped"
}
==========
    Medication
    ==========
{
    "display__c": "famotidine (PEPCID) tablet",
    "Epic_MedicationRequesId__c": "eAV.5YjW2fTOYmNIzSUZuzw3",
    "DataSourceObject__c": "EpicMedication_Epic_MedicationRequest_Medication_07E663C0",
    "Medication_Id__c": "e4a358bdlVtjl8Jqsf3-8uxCMYbXjkVvMVyPpwaGllFOHovwD4Om2FITQeIaJk13r3_eAV.5YjW2fTOYmNIzSUZuzw3",
    "DataSource__c": "EpicMedication_5601b1bc_c036_4dce_9680_a559c8bddcad",
    "id__c": "e4a358bdlVtjl8Jqsf3-8uxCMYbXjkVvMVyPpwaGllFOHovwD4Om2FITQeIaJk13r3"
}
============
    Practitioner
    ============
{
    "DataSource__c": "EpicMedication_5601b1bc_c036_4dce_9680_a559c8bddcad",
    "DataSourceObject__c": "EpicMedication_Epic_MedicationRequestPractitioer_ED6B1B2C",
    "Practitioner_Id__c": "eAV.5YjW2fTOYmNIzSUZuzw3_",
    "display__c": "Physician Family Medicine, MD",
    "Epic_MedicationRequestId__c": "eAV.5YjW2fTOYmNIzSUZuzw3",--------------------------------------------------MedicationRequestID
        "Practitioner_Type__c": "Practitioner"
}
,
{
    "DataSource__c": "EpicMedication_5601b1bc_c036_4dce_9680_a559c8bddcad",
    "DataSourceObject__c": "EpicMedication_Epic_MedicationRequestPractitioer_ED6B1B2C",
    "Practitioner_Id__c": "eAV.5YjW2fTOYmNIzSUZuzw3_",
    "display__c": "Physician Family Medicine, MD",
    "Epic_MedicationRequestId__c": "eAV.5YjW2fTOYmNIzSUZuzw3",------------------------------------------------MedicationRequestID
        "Practitioner_Type__c": "Practitioner"
}
 */
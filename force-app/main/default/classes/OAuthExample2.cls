public class OAuthExample2 {
    @AuraEnabled
    public static List<Object> getAccessToken2(String input) {
        String endpoint = 'https://login.salesforce.com/services/oauth2/token';
        String clientId = '3MVG9jSKmPAPVo2KSuUmd0_YbjzXRIjxzl8JreFyVg2LENX08V.TjmuOrRzNRp.lC4knRSaqytXHv2Fw1Llbw';
        String clientSecret = '2E6BC395244DE09EB4E262B002F96D31FBD97528BA42532B3B305A9CD58C4D2C';
        String username = 'abhay.kumar.yadav@techkasetti.com2024/07/25_15-30-0.demo';
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
/* //e.Rxkbv0HmfyDyboA-LtyRQ3 //2
(
{
    medicationRequest=(
    {
        category=Community,
        courseOfTherapyType=Short course (acute) therapy,
        id=emhFW-QGYoC9ijvvE.RB4cw3,
        identifier=882174,
        medications=({Medication_Id=e0Ew1aWmg6Y6qNCaOcI7KrbLwuOv1alZn5-InWqC4RQCerkX-9.LpqaKJagAzmpnH3_emhFW-QGYoC9ijvvE.RB4cw3, display=prenatal multivitamin tablet 90-600-400 mg-mcg-mcg, id=e0Ew1aWmg6Y6qNCaOcI7KrbLwuOv1alZn5-InWqC4RQCerkX-9.LpqaKJagAzmpnH3}),
        practioners=({Practitioner_Id=emhFW-QGYoC9ijvvE.RB4cw3_eHdBpsN5eOyFCM2cUPgGuTw3, Practitioner_Type=Practitioner, display=Physician Obstetrics, MD}),
        status=completed
    },
    {
        category=Community,
        courseOfTherapyType=Short course (acute) therapy,
        id=eJk0ebNUOTKx9f80aYoZPHg3,
        identifier=882173,
        medications=({Medication_Id=en0IpPR7jJ9u2aTvV-F20Tj7oIUehIqKfygWYu5Tt9l2GpPo3ZYvVCUT5TKmWwCU63_eJk0ebNUOTKx9f80aYoZPHg3, display=CALCIUM + D PO, id=en0IpPR7jJ9u2aTvV-F20Tj7oIUehIqKfygWYu5Tt9l2GpPo3ZYvVCUT5TKmWwCU63}),
        practioners=({Practitioner_Id=eJk0ebNUOTKx9f80aYoZPHg3_eyOHsvt3quDQ4aJ38tl.ywQ3, Practitioner_Type=Practitioner, display=Nurse Obstetrics, RN}),
        status=active
    }
    ),
    patientName=Beth Ambulatory
}
)
    // e63wRTbPfr1p8UW81d8Seiw3 //41
(
{
    medicationRequest=(
    {
        category=Community,
        courseOfTherapyType=Continuous long term therapy,
        id=e8tqF7AOiwUNhJaxzoIw0qg3,
        identifier=795609,
        medications=({Medication_Id=eA9IZM.lvQVOXTDPYrt97mlpkKP-IA8uqi13-ol1iBooh3tuU1tL0hPsqP0Rbdie13_e8tqF7AOiwUNhJaxzoIw0qg3, display=levothyroxine (SYNTHROID, LEVOTHROID) tablet, id=eA9IZM.lvQVOXTDPYrt97mlpkKP-IA8uqi13-ol1iBooh3tuU1tL0hPsqP0Rbdie13}),
        practioners=({Practitioner_Id=e8tqF7AOiwUNhJaxzoIw0qg3_eM5CWtq15N0WJeuCet5bJlQ3, Practitioner_Type=Practitioner, display=Physician Family Medicine, MD}),
        status=stopped
    },
    {
        category=Community,
        courseOfTherapyType=Short course (acute) therapy,
        id=exiz.ZObtxw12ValOoSpZlg3,
        identifier=795594,
        medications=({Medication_Id=eFaEzG1KIkTzmJpqIINo7DLDDQX6der9VagOhEqrEsBu8LhOOqS93TGadqaIvPhU43_exiz.ZObtxw12ValOoSpZlg3, display=codeine-guaiFENesin (ROBITUSSIN AC) solution, id=eFaEzG1KIkTzmJpqIINo7DLDDQX6der9VagOhEqrEsBu8LhOOqS93TGadqaIvPhU43}),
        practioners=({Practitioner_Id=exiz.ZObtxw12ValOoSpZlg3_eM5CWtq15N0WJeuCet5bJlQ3, Practitioner_Type=Practitioner, display=Physician Family Medicine, MD}),
        status=stopped
    },
    {
        category=Community,
        courseOfTherapyType=Short course (acute) therapy, id=ezRJR9pRLAVlJikiOqBYh5w3,
        identifier=795597,
        medications=({Medication_Id=eAMyTcggmIulnQ2tTBjDzeLJGWnb4Gyb5iha5xA-6VoIpTl25hRmM87kHjcdjbszl3_ezRJR9pRLAVlJikiOqBYh5w3, display=dilTIAZem (CARDIZEM CD) 24 hr capsule, id=eAMyTcggmIulnQ2tTBjDzeLJGWnb4Gyb5iha5xA-6VoIpTl25hRmM87kHjcdjbszl3}),
        practioners=({Practitioner_Id=ezRJR9pRLAVlJikiOqBYh5w3_eM5CWtq15N0WJeuCet5bJlQ3, Practitioner_Type=Practitioner, display=Physician Family Medicine, MD}),
        status=stopped
    },
    {
        category=Community,
        courseOfTherapyType=Short course (acute) therapy, id=eUBJukF5lrPNlfMMa9HDZXw3,
        identifier=795619,
        medications=({Medication_Id=e4a358bdlVtjl8Jqsf3-8u7P2TlVymu2JSwaXzeM036xgMhUA4pzQ9xbkvz3JagvE3_eUBJukF5lrPNlfMMa9HDZXw3, display=famotidine (PEPCID) tablet, id=e4a358bdlVtjl8Jqsf3-8u7P2TlVymu2JSwaXzeM036xgMhUA4pzQ9xbkvz3JagvE3}),
    practioners=({Practitioner_Id=eUBJukF5lrPNlfMMa9HDZXw3_eM5CWtq15N0WJeuCet5bJlQ3, Practitioner_Type=Practitioner, display=Physician Family Medicine, MD}), status=stopped}, {category=Community, courseOfTherapyType=Short course (acute) therapy, id=eZJROiQvIaaejlf3dbCFk.Q3, identifier=795528, medications=({Medication_Id=e0BheeIOZQc-iOBkCFq.OiIqJBNfJE0B9SDLPM99R.6SX6sKct.cGZvi3zZpI9LVO3_eZJROiQvIaaejlf3dbCFk.Q3, display=simvastatin (ZOCOR) tablet, id=e0BheeIOZQc-iOBkCFq.OiIqJBNfJE0B9SDLPM99R.6SX6sKct.cGZvi3zZpI9LVO3}), practioners=({Practitioner_Id=eZJROiQvIaaejlf3dbCFk.Q3_erqn5oyiA9.LpVQkQ2Ulmgg3, Practitioner_Type=Practitioner, display=Nurse Family Medicine, RN}), status=stopped}, {category=Community, courseOfTherapyType=Continuous long term therapy, id=e5NNEDjosAw.XzO1rL7jjlA3, identifier=795596, medications=({Medication_Id=eA9IZM.lvQVOXTDPYrt97mjbv.Tm.0SQbXZWtY8czyDq7JfX9NvCRjGlNw.dTTky53_e5NNEDjosAw.XzO1rL7jjlA3, display=levothyroxine (SYNTHROID, LEVOTHROID) tablet, id=eA9IZM.lvQVOXTDPYrt97mjbv.Tm.0SQbXZWtY8czyDq7JfX9NvCRjGlNw.dTTky53}), practioners=({Practitioner_Id=e5NNEDjosAw.XzO1rL7jjlA3_eM5CWtq15N0WJeuCet5bJlQ3, Practitioner_Type=Practitioner, display=Physician Family Medicine, MD}), status=stopped}, {category=Community, courseOfTherapyType=Continuous long term therapy, id=eOMPNfjFGsM8-tHu-XlhKGg3, identifier=795510, medications=({Medication_Id=ecQHtcUeYMZY3bU-i5wS-RjHvPbHLaVOjP8e8YYXlY6g4.zIkemSMsbADh37kEA6r3_eOMPNfjFGsM8-tHu-XlhKGg3, display=raNITIdine (ZANTAC) tablet, id=ecQHtcUeYMZY3bU-i5wS-RjHvPbHLaVOjP8e8YYXlY6g4.zIkemSMsbADh37kEA6r3}), practioners=({Practitioner_Id=eOMPNfjFGsM8-tHu-XlhKGg3_ebqdHGyh4nzNl573GUd3n2w3, Practitioner_Type=Practitioner, display=Admin Ambulatory}), status=active}, {category=Community, courseOfTherapyType=Continuous long term therapy, id=efvM5qpkvUBgJh5FqwCHEXg3, identifier=795525, medications=({Medication_Id=eA9IZM.lvQVOXTDPYrt97mouxjjiSRKLySZYWxtooEnI2npqIWgF2fuC5UQCp5Vz23_efvM5qpkvUBgJh5FqwCHEXg3, display=levothyroxine (SYNTHROID, LEVOTHROID) tablet, id=eA9IZM.lvQVOXTDPYrt97mouxjjiSRKLySZYWxtooEnI2npqIWgF2fuC5UQCp5Vz23}), practioners=({Practitioner_Id=efvM5qpkvUBgJh5FqwCHEXg3_eM5CWtq15N0WJeuCet5bJlQ3, Practitioner_Type=Practitioner, display=Physician Family Medicine, MD}), status=stopped}, {category=Community, courseOfTherapyType=Continuous long term therapy, id=eiOWgfIRUMAMXtjnWJjfprQ3, identifier=795512, medications=({Medication_Id=eQDEVHEtDuDIa0cKgnlYyN.Dbc1tmUn2T77rTQ1sn9St1MpfgIiVZoEaafPlCCOhd3_eiOWgfIRUMAMXtjnWJjfprQ3, display=atorvastatin (LIPITOR) tablet, id=eQDEVHEtDuDIa0cKgnlYyN.Dbc1tmUn2T77rTQ1sn9St1MpfgIiVZoEaafPlCCOhd3}), practioners=({Practitioner_Id=eiOWgfIRUMAMXtjnWJjfprQ3_ebqdHGyh4nzNl573GUd3n2w3, Practitioner_Type=Practitioner, display=Admin Ambulatory}), status=active}, {category=Community, courseOfTherapyType=Short course (acute) therapy, id=eN1-RQgDri5P8gf-IYzQD6w3, identifier=795625, medications=({Medication_Id=eBQbIRqmHguWneK5v8Og9Ew0sJaGJfB4G9QwrJr0jfddflL5BB2EIIfZBvWAftTI53_eN1-RQgDri5P8gf-IYzQD6w3, display=nicotine (NICODERM CQ) patch 14 mg/24 hr, id=eBQbIRqmHguWneK5v8Og9Ew0sJaGJfB4G9QwrJr0jfddflL5BB2EIIfZBvWAftTI53}), practioners=({Practitioner_Id=eN1-RQgDri5P8gf-IYzQD6w3_eM5CWtq15N0WJeuCet5bJlQ3, Practitioner_Type=Practitioner, display=Physician Family Medicine, MD}), status=stopped}, ...
    ),
    patientName=Theodore Mychart
}
)
     */
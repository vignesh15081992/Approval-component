/**
 * @description       : 
 * @author            : Cleberson Barbosa
 * @group             : 
 * @last modified on  : 05-12-2022
 * @last modified by  : Cleberson Barbosa
**/
@IsTest
public with sharing class FilterRegistriesTest {
    @IsTest
    public static void getInstance(){
        FilterRegistries filter =FilterRegistries.getInstance('BrPgdCampaign');
        FilterRegistries filter2 =FilterRegistries.getInstance('BrPgdCampaign');
        System.assertEquals(filter, filter2, 'Same instance');
        System.assertEquals('BrPgdCampaign', filter.metadataName, 'Same Name from metadata');

    }
    @IsTest
    public static void populateColumns(){
        FilterRegistries filter =FilterRegistries.getInstance('BrPgdCampaign');
        ProcessInstanceRepository repo = new ProcessInstanceRepository();
        List<MassApprovalProcessAttribute__mdt> metadatas=repo.getMetadata('BrPgdCampaign');
        filter.populateColumns(metadatas.get(0));
        System.assertEquals('BrPgdCampaign', filter.metadataName, 'Same Name from metadata');


    }
    @IsTest
    public static void populateFilters(){
        FilterRegistries filter =FilterRegistries.getInstance('BrPgdCampaign');
        ProcessInstanceRepository repo = new ProcessInstanceRepository();
        List<MassApprovalProcessAttribute__mdt> metadatas=repo.getMetadata('BrPgdCampaign');
        filter.populateFilters(metadatas.get(0));
        System.assertEquals('BrPgdCampaign', filter.metadataName, 'Same Name from metadata');

    }
    @IsTest
    public static void getConfiguration(){
        FilterRegistries filter =FilterRegistries.getInstance('BrPgdCampaign');
        ProcessInstanceRepository repo = new ProcessInstanceRepository();
        List<MassApprovalProcessAttribute__mdt> metadatas=repo.getMetadata('BrPgdCampaign');
        filter.getConfiguration('BrPgdCampaign');
        System.assertEquals('BrPgdCampaign', filter.metadataName, 'Same Name from metadata');

    }

    @IsTest
    public static void getReferenceField(){
        FilterRegistries filter =FilterRegistries.getInstance('BrPgdCampaign');
        ProcessInstanceRepository repo = new ProcessInstanceRepository();
        List<MassApprovalProcessAttribute__mdt> metadatas=repo.getMetadata('BrPgdCampaign');
        filter.populateColumns(metadatas.get(0));
        System.assertEquals('BrPgdCampaign', filter.metadataName, 'Same Name from metadata');
        FilterRegistries.TypeAttributes attirb=  new FilterRegistries.TypeAttributes();
        FilterRegistries.Options options=  new FilterRegistries.Options('1');
        FilterRegistries.Options options2=  new FilterRegistries.Options('2','1');
        new FilterRegistries.Filter('1',new Set<String>{'2'});

        System.assert(options.equals(options2), 'Same options' );

    }
}

funStruct = getAnalyticalFunctions();
%% load file
filename = 'MainStruct04122020.mat';
MainStruct = funStruct.LoadMainDataStructureStruct(filename);

%% add new data
if funStruct.CheckIfMainDataStrucreIsValid(MainStruct)
    addres='https://danepubliczne.imgw.pl/api/data/synop';
    newData = funStruct.GetDataFormVendor(addres);
    MainStruct = funStruct.AddNewData(newData,MainStruct);

    %% plot data -- podzielone na czêœci aby testowaæ dowolne wywo³ania funkcji PlotData
    funStruct.PlotDataStruct(MainStruct,'Bielsko Bia³a','temperatura',true)
    funStruct.PlotDataStruct(MainStruct,'M³awa','temperatura',true)
    funStruct.PlotDataStruct(MainStruct,'Warszawa','temperatura',true)
    %%
    funStruct.PlotDataStruct(MainStruct,'M³awa','temperatura')
    %%
    funStruct.PlotDataStruct(MainStruct,'Warszawa','cisnienie')
    %%
    funStruct.PlotDataStruct(MainStruct,'Warszawa','cisnienie',true)
    %% zapis danych

    filename = 'abcccccccccccc.mat';
    funStruct.SaveMainDataStructureStruct(MainStruct,filename);
end
funStruct = getAnalyticalFunctions();
%% load file
filename = 'maindataStructure03122020.mat';
Stations = funStruct.LoadMainDataStructure(filename);

%% add new data
if funStruct.CheckIfMainDataStrucreIsValid(Stations)
    addres='https://danepubliczne.imgw.pl/api/data/synop';
    newData = funStruct.GetDataFormVendor(addres);

    Stations = funStruct.AddNewData(newData,Stations);

    %% plot data -- podzielone na cz�ci aby testowa� dowolne wywo�ania funkcji PlotData
    funStruct.PlotData(Stations,'Bielsko Bia�a','temperatura',true)
    funStruct.PlotData(Stations,'M�awa','temperatura',true)
    funStruct.PlotData(Stations,'Warszawa','temperatura',true)
    %%
    funStruct.PlotData(Stations,'M�awa','temperatura')
    %%
    funStruct.PlotData(Stations,'Warszawa','cisnienie')
    %%
    funStruct.PlotData(Stations,'Warszawa','cisnienie',true)
    %%
    Stations1long = cell(1,62);
    for i = 1 : length(newData)
       Stations1long(i) = {{newData(i)}};
    end
    %%
    funStruct.PlotData(Stations1long,'Warszawa','cisnienie');
    %%
    funStruct.PlotData(Stations1long,'Bielsko Bia�a','temperatura',true)
    funStruct.PlotData(Stations1long,'M�awa','temperatura',true)
    funStruct.PlotData(Stations1long,'Warszawa','temperatura',true)
    %% save data
    filename = 'savedData2.mat';
    funStruct.SaveMainDataStructure(Stations,filename);
end
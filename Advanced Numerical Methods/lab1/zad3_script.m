urlAddress = 'https://danepubliczne.imgw.pl/api/data/synop';
filename = 'maindataStructure03122020.mat';
weather = WeatherClass(filename,urlAddress);

%%
NewData = weather.GetDataFormVendor;
weather.dataStructure = WeatherClass.addNewData(weather.dataStructure, NewData);
%%
weather.PlotData('Bielsko Bia³a','temperatura')
%%
weather.PlotData('Bielsko Bia³a','temperatura',true)
weather.PlotData('M³awa','temperatura',true)
weather.PlotData('Warszawa','temperatura',true)
%%
Stations1long = cell(1,62);
for i = 1 : length(NewData)
   Stations1long(i) = {{NewData(i)}};
end
%%
weather.dataStructure = Stations1long;
weather.PlotData('Warszawa','temperatura')

%% save
filename = 'savedDatafromClass.mat';
weather.SaveMainDataStructure(filename);
b = PadsRecognition('PCB1.jpg');
b.perspectiveFix;

h = images.roi.Line(gca,'Position',[100 150;400 650]);

%%
im = b.Image;
sz = size(im);
myData.Units = 'pixels';
myData.MaxValue = hypot(sz(1),sz(2));
myData.Colormap = hot;
myData.ScaleFactor = 1;
hIm = imshow(im);

hIm.ButtonDownFcn = @(~,~) startDrawing(hIm.Parent,myData);
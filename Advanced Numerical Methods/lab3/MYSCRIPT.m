figure
a = PadsRecognition('PCB1.jpg');
a.perspectiveFix;
a.analyze;
[x,y] = a.allPadsPosition;

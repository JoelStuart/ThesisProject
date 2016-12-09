clear
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read in input file
[FileName,PathName,FilterIndex] = uigetfile('*.txt');
if FileName ~= 0
    filePath = strcat(PathName,FileName);
    fid = fopen(filePath);
    tline = fgetl(fid);
    f = 1;
    %If first char is not number -> named TLE file
    if ~isstrprop(tline(1), 'digit') 
        %Strip every first line in 3
        f = 2/3;
    end
    %Get number of rows in file
    rows = numel(textread(filePath,'%1c%*[^\n]'));
    Nrows = rows*f;
    
    %Init c - cell array storing TLE elements
    c = cell([Nrows, 1]);
    count = 1;
    while ischar(tline)
        %disp(tline);
        %%if first char not number
        if isstrprop(tline(1), 'digit')
            c(floor(count*f),1) = cellstr(tline);
        end 
        count = count + 1;
        tline = fgetl(fid);
    end
else
    fprintf('User cancelled file select.\n');
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get number of particles from user input
partNum = input('Input particle count:');
startmfe = 0;
stopmfe = 1;
deltamin = 0.1;
tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialise Arrays

%Init data array
objs = Nrows/2*partNum;
%d = zeros(sze,objs,3);
fps = 10;

fprintf('Calculating...\n');
julian_time = juliandate(clock);
%Iridium 33
%julian_time = 2454873.201389;


%Particle error settings

% rInclo = 0.01;
% rNodeo = 0.01;
% rEcco = 0.00001;
% rArgpo = 0.01;
% rMo = 0.5;
% rNo = 0.00001;

rInclo = 0.0005;
rNodeo = 0.0005;
rEcco = 0.00001;
rArgpo = 0.0005;
rMo = 0.00001;
rNo = 0.00001;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Declare arrays

%Set rows to 1 for minimum memory usage -> set high for smoother animation,
%higher memory cost -> may cause Out of VRAM crash (restart MATLAB to fix)
rows = 1;
cols = objs;   %data array

%Output sizes to console
fprintf('\nNo. frames per gpu chunk: %d ... & No. objs: %d -> ', rows, objs);
fprintf('Total frames: %d\n', rows*objs);

%Init gpu arrays
satnum = zeros(1, objs);
jdsatepoch = zeros(1, objs);
tsepoch = zeros(1, objs);
bstar = zeros(1, objs);
ecco = zeros(1, objs);
argpo = zeros(1, objs);
inclo = zeros(1, objs);
no = zeros(1, objs);
mo = zeros(1, objs);
nodeo = zeros(1, objs);

for i = 1:2:Nrows
    %Process input strings into two lines
    line1 = c{i,1};
    line2 = c{i+1,1};
    j = floor(i/2);
        
    %return satrec for each object in TLE
    [satrec] = tleToSatrecO(7210, line1, line2, 'm', 'j', startmfe, stopmfe, deltamin);
    
    %Populate GPUArrays with satrec struct values
    for x = 1:(partNum)
        
        satnum(partNum*j+x) = satrec.satnum;
        %timeepoch = satrec.epochyr * 365.25 + satrec.epochdays;
        tsepoch(partNum*j+x) = julian_time - satrec.jdsatepoch;
        %satrec.jdsatepoch
        jdsatepoch(partNum*j+x) = satrec.jdsatepoch;
        bstar(partNum*j+x) = satrec.bstar;
        ecco(partNum*j+x) = satrec.ecco + rEcco*(rand*2-1);
        argpo(partNum*j+x) = satrec.argpo + rArgpo*(rand*2-1);
        inclo(partNum*j+x) = satrec.inclo + rInclo*(rand*2-1);
        mo(partNum*j+x) = satrec.mo + rMo*(rand*2-1);
        no(partNum*j+x) = satrec.no + rNo*(rand*2-1);
        nodeo(partNum*j+x) = satrec.nodeo + rNodeo*(rand*2-1);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GPU

fprintf('... ');
%Init result array
res = zeros(1, rows*cols*3);

%Send data to GPU
d_Result = gpuArray(res);

d_satnum = gpuArray(satnum);
d_jdsatepoch = gpuArray(jdsatepoch);
d_bstar = gpuArray(bstar);
d_ecco = gpuArray(ecco);
d_argpo = gpuArray(argpo);
d_inclo = gpuArray(inclo);
d_mo = gpuArray(mo);
d_no = gpuArray(no);
d_nodeo = gpuArray(nodeo);
d_tsepoch = gpuArray(tsepoch);

fprintf('... ');

%Initialise GPU Kernel
kernel = parallel.gpu.CUDAKernel('Prop_demo.ptx' , 'Prop_demo.cu' );
kernel.ThreadBlockSize = [sqrt(kernel.MaxThreadsPerBlock) , sqrt(kernel.MaxThreadsPerBlock),1];
kernel.GridSize = [ceil( cols / kernel.ThreadBlockSize(1)) , ceil( rows / kernel.ThreadBlockSize(2) )];

fprintf('... ');

%Run Parallel Code starting at time 0
t = 0;
d_Result = feval(kernel, d_Result, rows, cols, t, deltamin, d_jdsatepoch, d_bstar, d_ecco, d_argpo, d_inclo, d_mo, d_no, d_nodeo, d_tsepoch);

%Retreive Data from GPU
Result = gather(d_Result);
fprintf('...\n');
    

fprintf('Calculations finished in: ');        
tEnd = toc;
fprintf('%d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup visualsation window
hold on;
set(gca,'projection','perspective','cameraviewanglemode','manual','clipping','off', 'color','none');
axis([-8000, 8000, -8000, 8000, -8000, 8000]);
axis off
view([45,45])

%Initialise object draw array
drawObjs = zeros(objs, 3);

%Populate drawObjects wth time 0 results
for j = 1:objs
    drawObjs(j, 1) = Result(1 + rows*(j-1+objs*0));
    drawObjs(j, 2) = Result(1 + rows*(j-1+objs*1));
    drawObjs(j, 3) = Result(1 + rows*(j-1+objs*2));
end
x = drawObjs(:, 1);
y = drawObjs(:, 2);
z = drawObjs(:, 3);

%Initialise colour mappings for N = objs
rgb = hsv(objs);
hsv = rgb2hsv(rgb);
hsv(:, :, 1) = hsv(:, :, 1) * .85;
colour =  hsv2rgb(hsv);

%Plot scatter plot
h = scatter3(x,y,z, 4, colour,'filled');
set(h, 'MarkerEdgeAlpha', 1);
% set(h, {'MarkerEdgeColor'},);

%Draw earth
eTex = imread('earthmap.jpg');
[x1, y1, z1] = sphere(100);
earth = surf(x1*6000,y1*6000,z1*6000, 'EdgeColor','none');
set(earth,'CData',flipud(eTex),'FaceColor', 'texturemap');

%Setup UI and window appearance
set(gcf, 'Position', [40 80 1000 800], 'Name', 'SGP4 Demo');
cameratoolbar
          
%% Init write to file    
fileID = fopen('PropOut.txt','w');
fclose(fileID);
fileID = fopen('PropOut.txt','a');
fprintf(fileID,'%d\n',Nrows/2);
fprintf(fileID,'%d\n',partNum);
fclose(fileID);

            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Draw loop 
while (1)
%for i = 1:floor(sze/(stopmfe/deltamin)):sze
for ii = 1:rows
    tic;
    
    if (ii == 1 && t ~= 0)
        %Compute new values for next time steps
        d_Result = feval(kernel, d_Result, rows, cols, t, deltamin, d_jdsatepoch, d_bstar, d_ecco, d_argpo, d_inclo, d_mo, d_no, d_nodeo, d_tsepoch);
        
        %Retreive Data from GPU
        Result = gather(d_Result); 
    end
    
    %Print timestep to file
    timestep = t + ii;
    fileID = fopen('PropOut.txt','a');
    fprintf(fileID,'Timestep %d\n',timestep);
    
    %Update drawObj array for all objects and print to file
    for j = 1:objs
        drawObjs(j, 1) = Result(ii + rows*(j-1+objs*0));
        drawObjs(j, 2) = Result(ii + rows*(j-1+objs*1));
        drawObjs(j, 3) = Result(ii + rows*(j-1+objs*2));
        fprintf(fileID,'%d %8.10f %8.10f %8.10f\n',j, drawObjs(j,1), drawObjs(j,2), drawObjs(j,3));
        
    end
    fclose(fileID);
    
    %Get each position matrix for objects at time ii
    x = drawObjs(:, 1);
    y = drawObjs(:, 2);
    z = drawObjs(:, 3);
    
    %Update plot with position data
    set(h, 'xdata', x, 'ydata', y, 'zdata', z);
    drawnow;
    %Pause to retain smooth playback according to fps
    pause(1/fps-toc);
end
%Increment timestep number by 'chunk' size
t = t + rows;
end
fprintf('Finished');





% -----------------------------
% Function: Reads BEM data from Files for NREL5MW wind turbine
% FoilNm, NumFoil, and BldNodes could be read in as well, but is  avoided 
% to similfy the code. Further, importdata could be used instead of fopen, 
% textscan, and fclose, but usually takes more time.
% ------------
% Input:
% none
% ------------
% Output:
% - BEM         struct of BEM data
% ----------------------------------
function BEM = ReadAirfoils (AeroFile)

% Open the file
fid             = fopen(AeroFile);

% Number of airfoil files:
for iLinesSkipped = 1:15
    fgetl(fid); % skip line
end

CurrentLine     = fgetl(fid);
BEM.NumFoil     = cell2mat(textscan(CurrentLine,'%f'));
% Read the airfoil files names:

FoilNm = strings(BEM.NumFoil,1);
for iAirfoil = 1:BEM.NumFoil
    CurrentLine         = fgetl(fid);
    FoilNm(iAirfoil,1)	= erase(extractBetween(CurrentLine,'"','"'),'"');
end

% Get the number BldNodes
CurrentLine     = fgetl(fid);
BEM.BldNodes    = cell2mat(textscan(CurrentLine,'%f'));

% Get data from AeroFile and load data into output variables
fgetl(fid);     % skip line
NodeData        = textscan(fid,'%f %f %f %f %d %s');

% close file
fclose(fid);

% get NodeData into structure
BEM.RNodes  	= NodeData{1};
BEM.AeroTwst 	= NodeData{2};
BEM.DRNodes     = NodeData{3};
BEM.Chord       = NodeData{4};
BEM.NFoil       = NodeData{5};
            
% Get data from AirfoilFiles and load data into output variables
for iAirfoil = 1:BEM.NumFoil
    AirfoilFile         = FoilNm{iAirfoil};
    fid                 = fopen(AirfoilFile);
    AirfoilData         = textscan(fid,'%f %f %f %f','HeaderLines',14);
    fclose(fid);
    BEM.AoA{iAirfoil}   = AirfoilData{1};
    BEM.Cl{iAirfoil}    = AirfoilData{2};
    BEM.Cd{iAirfoil}    = AirfoilData{3};
    BEM.Cm{iAirfoil}    = AirfoilData{4};       
end
end
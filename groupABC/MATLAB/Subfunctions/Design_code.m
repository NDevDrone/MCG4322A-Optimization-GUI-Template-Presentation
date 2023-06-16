% This function serves as the primary "design" function that is called by the GUI.
% All calculations and function calls go here.
% Use as many subfunctions as you'd like to organize your code.
function Design_code(axial_force, number_of_weights, shaft_length)
    %pwd gets current directory, then the directory suffix is extracted.
    directory_prefix_string = extractBefore(pwd, "groupABC");    
    %Check if the user tries to run this file directly by checking if a
    %variable has been passed here from the GUI (e.g. we use
    %'axial_force'). If so, open the GUI instead.
    if ~exist('axial_force','var')
        cd_loc = strcat(directory_prefix_string, '/groupABC/MATLAB/');
        run_loc = strcat(directory_prefix_string, '/groupABC/MATLAB/MAIN.mlapp');
        cd(cd_loc);
        run(run_loc); 
        return
    end
    % -----------1. Design calculations --------------------%
    % Put your analysis and optimization calculations here.
    default_diameter = 0.5; %Units (mm). Sets an initial diameter value.
    strength_al = 31; %Units (MPa). Assuming 1100-0 Al alloy, 
    % Call to a subfunction that optimizes for new shaft diameter.
    new_diameter = calc_shaft_diameter(default_diameter, strength_al, axial_force, number_of_weights, shaft_length); 
    
    % -----------2. Write text to equation file(s) --------%
	% Write the equations text file(s) that were linked within Solidworks.
	% These files must have the exact same formatting as the original text
	% File originally linked to Solidworks to ensure Solidworks can
	% interpret them. 
    shaft_file = strcat(directory_prefix_string, '/groupABC/SolidWorks/Equations/shaft.txt');
    fid = fopen(shaft_file,'w+t');
    fprintf(fid,strcat('"Diameter"=',num2str(new_diameter),'\n'));
    fprintf(fid,strcat('"Length"=',num2str(shaft_length),'\n'));
    fclose(fid);
    
    % -----------3. Write text to log file ----------------%
    % Write the log file used to present optimization results to the user.
    % Declaring text files to be modified
    log_file = strcat(directory_prefix_string,'/groupABC/Log/groupABC_LOG.TXT');
       
    %Create only one log file for the complete project. Keep the file easy
	%to read by adding blank lines and sections. For string writing specifics, refer
	%to MATLAB documentation links below:
    % https://www.mathworks.com/help/matlab/ref/fopen.html
    % https://www.mathworks.com/help/matlab/ref/strcat.html
    % https://www.mathworks.com/help/matlab/ref/num2str.html
    % '\n' inputs a 'newLine' on the string, akin to a 'return' key press. 
    fid = fopen(log_file,'w+t');
	fprintf(fid,'*-- Shaft Design -- *\n\n');
    fprintf(fid,'The following input parameters were selected: \n');
    fprintf(fid,strcat('Axial force =',32,num2str(axial_force),' N.\n'));
	fprintf(fid,strcat('Shaft length =',32,num2str(shaft_length),' mm.\n'));
	fprintf(fid,strcat('There will be',32,num2str(10*number_of_weights),' kg of total weight hung at the end of the beam.\n \n'));
    fprintf(fid,'The following design outputs were found after the analysis and optimization steps were performed: \n');
    fprintf(fid,strcat('Optimized shaft diameter =',32,num2str(new_diameter),' (mm).\n \n'));
    fprintf(fid,'The following assumptions were made for the beam design calculations: \n');
    fprintf(fid,strcat('The shaft is made of 1100-0 Aluminm alloy.\n'));
    fprintf(fid,strcat('There is no torque loading on the shaft.\n \n'));
	fclose(fid);    
end

% An example of a subfunction, written within the same file as design_code.m 
% Make note that the inputs within the parentheses have different names than
% the arguments named in the original function call. 
% Only the sequence and data type of the arguments are passed to functions.
function new_diameter = calc_shaft_diameter(diameter, str, axial_force, number_of_weights, shaft_length)
	%Eq. (##) <- Add a reference to the equation in your report.
    %In this case, we calculate the Von Mises stress from inputs. 
    % Ignore torque input (as it is zero for this example).
	
    bending_force = (9.81)*10*number_of_weights; % 10 kg weights,
    n = 0;   %Initial safety factor
    
    %Optimization loop, iteratively calculate diameter until safety factor 'n' > 1.5
    while n<1.5
        diameter = diameter + 0.001;
        stress = (((4*axial_force)/(pi*(diameter^2)))+((32*bending_force*shaft_length)/(pi*(diameter^3))));    
        n = str/stress;
    end
    
    new_diameter = diameter;
end
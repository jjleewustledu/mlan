classdef (Sealed) Ccir993Registry < handle & mlnipet.StudyRegistry
	%% CCIR993REGISTRY 
    %
	%  $Revision$
 	%  was created 15-Oct-2015 16:31:41
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
    properties
        projectsDir
        projectFolder
        snakes
    end
    
    properties (Dependent)
        subjectsJson
    end
    
    methods % GET
        function g = get.subjectsJson(this)
            if isempty(this.subjectsJson_)
                this.subjectsJson_ = jsondecode( ...
                    fileread(fullfile(this.projectsDir, this.projectFolder, 'constructed_20191108.json')));
            end
            g = this.subjectsJson_;
        end
    end

    methods
        function dt = ses2dt(this, ses)
            ses = strsplit(ses, '-');
            ses = ses{2};
            j = this.subjectsJson;
            for f = asrow(fields(j))
                if contains(j.(f{1}).experiments, ses)
                    dfield = fields(j.(f{1}).dates);
                    dt = j.(f{1}).dates.(dfield{1});
                    dt = datetime(dt, 'InputFormat', 'yyyyMMdd');
                    return
                end
            end
        end
        function ses = dt2ses(this, dt)
            ds = datestr(dt, 'yyyymmdd');
            j = this.subjectsJson;
            for f = asrow(fields(j))
                dfield = fields(j.(f{1}).dates);
                if strcmp(ds, j.(f{1}).dates.(dfield{1}))
                    ses = j.(f{1}).experiments;
                    ses = strsplit(ses{1}, '_');
                    ses = strcat('ses-', ses{2});
                    return
                end
            end
        end
        function ses = sub2ses(this, sub)
            sub = strsplit(sub, '-');
            sub = sub{2};
            j = this.subjectsJson;
            for f = asrow(fields(j))
                if contains(j.(f{1}).sid, sub)
                    ses = j.(f{1}).experiments;
                    ses = strsplit(ses{1}, '_');
                    ses = strcat('ses-', ses{2});
                    return
                end
            end
        end
        function sub = ses2sub(this, ses)
            ses = strsplit(ses, '-');
            ses = ses{2};
            j = this.subjectsJson;
            for f = asrow(fields(j))
                if contains(j.(f{1}).experiments, ses)
                    sub = j.(f{1}).sid;
                    sub = strsplit(sub, '_');
                    sub = strcat('sub-', sub{2});
                    return
                end
            end
        end
        
        function sub = x0993_to_sub(this, x0993)
            %  Args:
            %      x0993 (text,numeric):  e.g. 2 '2' "002" "x0993_002" "x993_011"
            %  Returns:
            %      sub:  text, e.g., 'sub-S12345'

            if isnumeric(x0993) && x0993 == 11
                x0993 = "x993_011";
            end
            if isnumeric(x0993)
                x0993 = "x0993_" + num2str(x0993, '%03i');
            end
            if length(char(x0993)) < 3
                x0993 = num2str(str2double(x0993), '%03i');
            end
            if ~all(contains(x0993, "x0993_"))
                x0993 = "x0993_" + x0993;
            end
            if contains(x0993, "_011")
                x0993 = "x993_011";
            end

            j = this.subjectsJson;
            sub = j.(x0993).sid;
            sub = strsplit(sub, "_");
            sub = strcat('sub-', sub{2});
        end
        function x = sub_to_x0993(this, sub)
            sub = strsplit(sub, '-');
            sub = sub{2};
            j = this.subjectsJson;
            for f = asrow(fields(j))
                if contains(j.(f{1}).sid, sub)
                    x = f{1};
                    return
                end
            end
        end
    end
    
    methods (Static)
        function t = consoleTaus(tracer)
            t = mlan.Ccir993Scan.consoleTaus(tracer);
        end 
        function this = instance(reset)
            arguments
                reset = []
            end
            persistent uniqueInstance
            if ~isempty(reset)
                uniqueInstance = [];
            end
            if (isempty(uniqueInstance))
                this = mlan.Ccir993Registry();
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end  
    
    
    %% PRIVATE

	methods (Access = private)		  
 		function this = Ccir993Registry()
            this.atlasTag = 'on_T1w';
            this.projectsDir = getenv('SINGULARITY_HOME');
            this.projectFolder = 'CCIR_00993';
            this.reconstructionMethod = 'e7';
            this.referenceTracer = 'HO';
            this.tracerList = {'oc' 'oo' 'ho'};
            this.T = 0;
            this.umapType = 'deep';

            this.snakes.contractBias = 0.2;
            this.snakes.iterations = 80;
            this.snakes.smoothFactor = 0;
 		end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end


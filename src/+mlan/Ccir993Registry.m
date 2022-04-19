classdef (Sealed) Ccir993Registry < handle & mlnipet.StudyRegistry
	%% STUDYREGISTRY 

	%  $Revision$
 	%  was created 15-Oct-2015 16:31:41
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
    methods (Static)
        function this = instance(varargin)
            %% INSTANCE
            %  @param optional qualifier is char \in {'initialize' ''}
            
            ip = inputParser;
            addOptional(ip, 'qualifier', '', @ischar)
            parse(ip, varargin{:})
            
            persistent uniqueInstance
            if (strcmp(ip.Results.qualifier, 'initialize'))
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
    
    properties
        Ddatetime0 % seconds
        ignoredExperiments = {}
        projectFolder = 'CCIR_00993'
        referenceTracer = 'HO'
        T = 10 % sec at the start of artery_interpolated used for model but not described by scanner frames
        tracerList = {'oc' 'oo' 'ho'}
        umapType = 'deep'
    end
    
    properties (Dependent)
        projectsDir
        rawdataDir
        sessionsDir
        subjectsDir	
        subjectsJson
        tBuffer
    end
    
    methods
        
        %% GET
        
        function g = get.projectsDir(~)
            g = getenv('SINGULARITY_HOME');
        end
        function x = get.rawdataDir(this)
            x = fullfile(this.projectsDir, this.projectFolder, 'rawdata');
        end
        function g = get.sessionsDir(this)
            g = fullfile(this.projectsDir, this.projectFolder, 'derivatives', 'nipet', '');
        end
        function g = get.subjectsDir(this)
            g = fullfile(this.projectsDir, this.projectFolder, 'derivatives', 'resolve', '');
        end
        function g = get.subjectsJson(this)
            if isempty(this.subjectsJson_)
                this.subjectsJson_ = jsondecode( ...
                    fileread(fullfile(this.projectsDir, this.projectFolder, 'constructed_20191108.json')));
            end
            g = this.subjectsJson_;
        end
        function g = get.tBuffer(this)
            g = max(0, -this.Ddatetime0) + this.T;
        end

        %%

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
    
    %% PRIVATE
    
    properties (Access = private)
        subjectsJson_
    end

	methods (Access = private)		  
 		function this = Ccir993Registry(varargin)
            this = this@mlnipet.StudyRegistry(varargin{:});
 		end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end


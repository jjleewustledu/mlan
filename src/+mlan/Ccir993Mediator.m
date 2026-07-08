classdef Ccir993Mediator < handle & mlpipeline.ImagingMediator
    %% Ccir993Mediator provides a mediator design pattern for project CCIR993 (cf. GoG pp. 276-278).  
    %  As a mediator, it separates and manages data-conceptual entities previously squashed into class 
    %  hierarchies such as that for mlan.SessionData.
    %
    %  It also provides a prototype design pattern for use by abstract factories like mlkinetics.BidsKit 
    %  (cf. GoF pp. 90-91, 117).  For prototypes, call initialize(obj) using obj understood by 
    %  mlfourd.ImagingContext2.  Delegates data-conceptual functionality to mlvg.{Ccir993Scan, Ccir993Session, 
    %  Ccir993Subject, Ccir993Project, Ccir993Study}.
    %  
    %  Created 04-Apr-2023 15:25:24 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.14.0.2206163 (R2023a) for MACI64.  Copyright 2023 John J. Lee.
    
    properties
        defects
        metric
        rnumber = 2
    end

    methods
        function this = Ccir993Mediator(varargin)
            %% Args must be understandable by mlfourd.ImagingContext2.

            this = this@mlpipeline.ImagingMediator(varargin{:});
            this.initialize();
        end
        function [this,T] = findProximal(this, index, patt)
            arguments
                this mlan.Ccir993Mediator
                index double = 1
                patt {mustBeTextScalar} = "sub-*_ses-*_trc-fdg_proc-dyn_pet.nii.gz"
            end

            % table:  dt, fqfn
            g = glob(fullfile(this.subjectsPath, "sub-*", "ses-*", this.scanFolder, patt));
            T = cell2table(cellfun(@(x) this.datetime_bids_filename(x), g, UniformOutput=false));
            T = addvars(T, g);
            T.Properties.VariableNames = ["dt", "fqfn"];

            % table:  dt, sep, fqfn; sorted by sep
            current = contains(T.fqfn, this.imagingContext.filename);
            sep = days(abs(T.dt - T.dt(current)));
            T = addvars(T, sep, After="dt", NewVariableNames="sep");
            T = sortrows(T, "sep"); % ascending

            % find proximal Ccir1211Mediator
            fqfn1 = T.fqfn{1+index};
            this = mlan.Ccir993Mediator(fqfn1);
        end
        function this = initialize(this, varargin)
            this.buildImaging(varargin{:});
            this.bids_ = mlan.Ccir993Bids( ...
                destinationPath=this.scanPath, ...
                projectPath=this.projectPath, ...
                subjectFolder=this.subjectFolder);
            this.imagingAtlas_ = this.bids_.atlas_ic;
            try
                this.imagingDlicv_ = this.bids_.dlicv_ic;
            catch ME
                disp(ME)
            end          
        end
    end

    methods (Static)
        function this = create(varargin)
            this = mlan.Ccir993Mediator(varargin{:});
        end
    end
    
    %% PROTECTED

    methods (Access = protected)        
        function buildImaging(this, imcontext)
            arguments
                this mlan.Ccir993Mediator
                imcontext = this.imagingContext
            end
            if ~isempty(imcontext)
                this.imagingContext_ = mlfourd.ImagingContext2(imcontext);
            end

            this.scanData_ = mlan.Ccir993Scan(this, dataPath=this.imagingContext_.filepath);
            this.sessionData_ = mlan.Ccir993Session(this, dataPath=this.scansPath);
            this.subjectData_ = mlan.Ccir993Subject(this, dataPath=this.sessionsPath);
            this.projectData_ = mlan.Ccir993Project(this, dataPath= ...            
                this.omit_bids_folders(this.subjectsPath));
            this.studyData_ = mlan.Ccir993Study(this, mlan.Ccir993Registry.instance());

            % additional assembly required?

        end
    end

    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end

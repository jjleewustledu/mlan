classdef SubjectData < mlnipet.SubjectData2022
	%% SUBJECTDATA

	%  $Revision$
 	%  was created 05-May-2019 22:06:27 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
 	%% It was developed on Matlab 9.5.0.1067069 (R2018b) Update 4 for MACI64.  Copyright 2019 John Joowon Lee.
 	
    properties (Constant)
        TRACERS = {'OC' 'OO' 'HO'}
        EXTS = {'.4dfp.hdr' '.4dfp.ifh' '.4dfp.img' '.4dfp.img.rec'};
    end
    
    methods (Static)
        function obj = createProjectData(varargin)
            obj = mlan.ProjectData(varargin{:});
        end
        function sesf = subFolder2sesFolder(subf)
            sesf = mlan.SubjectData.subFolder2sesFolders(subf);
            if iscell(sesf)
                sesf = sesf{1};
            end
        end
        function sesf = subFolder2sesFolders(subf)
            %% requires well-defined cell-array this.subjectsJson.
            %  @param subf is a subject folder.
            %  @returns first-found non-trivial session folder in the subject folder.
            
            this = mlan.SubjectData('subjectFolder', subf);
            subjects = fields(this.subjectsJson_);
            ss = split(subf, '-');
            sesf = {};
            for s = asrow(subjects)
                subjectStruct = this.subjectsJson_.(s{1});
                if lstrfind(subjectStruct.id, ss{2}) || lstrfind(subjectStruct.sid, ss{2})
                    sesf = [sesf this.findExperiments(subjectStruct, subf)]; %#ok<AGROW>
                end
            end 
        end
    end

	methods
        function tf   = hasScanFolders(this, ~, sesf)
            %% legacy folders CCIR_*/derivatives/nipet/ses-E*/HO_DT*.000000-Converted-*/
            %  @param subf
            %  @param sesf
            
            reg = this.studyRegistry_;
            if ~isfolder(fullfile(reg.sessionsDir, sesf, ''))
                tf = false;
                return
            end
            globbed = globFoldersT( ...
                fullfile(reg.sessionsDir, sesf, '*_DT*.000000-Converted-AC', ''));
            tf = ~isempty(globbed);
        end

 		function this = SubjectData(varargin)
 			%% SUBJECTDATA
 			%  @param .

 			this = this@mlnipet.SubjectData2022(varargin{:});

            this.studyRegistry_ = mlan.Ccir993Registry.instance;
            this.subjectsJson_ = this.studyRegistry_.subjectsJson;
 		end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end


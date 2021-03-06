classdef SubjectData < mlnipet.SubjectData
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
        function sesf = subFolder2sesFolders(subf)
            %% requires well-defined cell-array this.subjectsJson.
            %  @param subf is a subject folder.
            %  @returns first-found non-trivial session folder in the subject folder.
            
            import mlan.SubjectData
            json = mlan.StudyRegistry.instance().subjectsJson;
            subjects = fields(json);
            ss = split(subf, '-');
            sesf = {};
            for s = asrow(subjects)
                subS = json.(s{1});
                if lstrfind(subS.id, ss{2}) || lstrfind(subS.sid, ss{2})
                    sesf = [sesf SubjectData.findExperiments(subS, subf)]; %#ok<AGROW>
                end
            end 
        end
        function sesf = subFolder2sesFolder(subf)
            sesf = mlan.SubjectData.subFolder2sesFolders(subf);
            if iscell(sesf)
                sesf = sesf{1};
            end
        end
    end

	methods        
 		function this = SubjectData(varargin)
 			%% SUBJECTDATA
 			%  @param .

 			this = this@mlnipet.SubjectData(varargin{:});

            this.studyRegistry_ = mlan.StudyRegistry.instance;
            this.subjectsJson_ = this.studyRegistry_.subjectsJson;
 		end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end


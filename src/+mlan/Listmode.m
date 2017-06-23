classdef Listmode < mlan.AbstractIO
	%% LISTMODE supports listmode data from the Siemens Biograph mMR. 

	%  $Revision$
 	%  was created 20-Jun-2017 12:18:36 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties (Constant)
        xdim = 344
        ydim = 252
        zdim = 4084
    end
    
    properties (Dependent)
        lhdrParser
        max_ring_difference
        mhdrParser
        nbuckets
        nsegments
        number_of_rings
        segtable
        sinoNumel
        studyDate
        studyTime
        wordCounts % listmode bytes / 4
    end
    
	methods 
        
        %% GET
        
        function g = get.lhdrParser(this)
            g = this.lhdrParser_;
        end
        function g = get.max_ring_difference(this)
            g = this.max_ring_difference_;
        end
        function g = get.mhdrParser(this)
            g = this.mhdrParser_;
        end
        function g = get.nbuckets(this)
            g = this.nbuckets_;
        end
        function g = get.nsegments(this)
            g = this.nsegments_;
        end
        function g = get.number_of_rings(this)
            g = this.number_of_rings_;
        end
        function g = get.segtable(this)
            g = this.segtable_;
        end
        function g = get.sinoNumel(this)
            g = this.xdim*this.ydim*this.zdim;
        end
        function g = get.studyDate(this)
            g = this.studyDate_;
        end
        function g = get.studyTime(this)
            g = this.studyTime_;
        end
        function g = get.wordCounts(this)
            g = this.wordCounts_;
        end
        
        %%
		          
        function s = curlyString2numeric(~, s)
            s = strrep(s, '{', '[');
            s = strrep(s, '}', ']');
            s = str2num(s); %#ok<ST2NM>
        end
            
 		function this = Listmode(varargin)
 			%% LISTMODE
 			%  Usage:  this = Listmode()

 			ip = inputParser;
            addParameter(ip, 'filepath', pwd, @isdir)
            addParameter(ip, 'fileprefix', 'Motion-LM-00', @ischar);
            parse(ip, varargin{:});
            
            this.filepath = ip.Results.filepath;
            this.fileprefix = ip.Results.fileprefix;
            this.filesuffix = '.l';
            import mlsiemens.*;
            this.lhdrParser_ = LhdrParser('filepath', ip.Results.filepath, 'fileprefix',  ip.Results.fileprefix);
            this.mhdrParser_ = MhdrParser('filepath', ip.Results.filepath, 'fileprefix', [ip.Results.fileprefix '-OP']);
            
            this.max_ring_difference_ = ...
                               this.lhdrParser_.parseSplitNumeric('%maximum ring difference');
            this.nbuckets_   = this.lhdrParser_.parseSplitNumeric('%total number of singles blocks');
            this.nsegments_  = this.lhdrParser_.parseSplitNumeric('%number of segments');
            this.number_of_rings_ = ...
                               this.lhdrParser_.parseSplitNumeric('number of rings');
            this.segtable_   = this.curlyString2numeric( ...
                               this.lhdrParser_.parseSplitString('%segment table'));
            this.studyDate_  = this.lhdrParser_.parseSplitString('%study date (yyyy:mm:dd)');
            this.studyTime_  = this.lhdrParser_.parseSplitString('%study time (hh:mm:ss GMT+00:00)');
            this.wordCounts_ = this.lhdrParser_.parseSplitNumeric('%total listmode word counts'); 
 		end
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        lhdrParser_
        max_ring_difference_
        mhdrParser_
        nbuckets_
        nsegments_
        number_of_rings_
        segtable_
        studyDate_
        studyTime_
        wordCounts_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end


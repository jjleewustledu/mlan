classdef Test_SortLMMotionMatlab < matlab.unittest.TestCase
	%% TEST_SORTLMMOTIONMATLAB 

	%  Usage:  >> results = run(mlan_unittest.Test_SortLMMotionMatlab)
 	%          >> result  = run(mlan_unittest.Test_SortLMMotionMatlab, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 16-Jun-2017 00:49:16 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlan/test/+mlan_unittest.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties
 		registry
 		testObj
        pwd0
        pwdWilliam = '/data/anlab/Hongyu/Phantom_24Jan2017/Gated'
        pwdMac = '~/Tmp'
        mhdr0 = 'Motion-LM-00-umap-hardware.mhdr'
 	end

	methods (Test)
        function test_lhdrParser(this)
            lhdr = mlsiemens.LhdrParser('fileprefix', 'Motion-LM-00-OP');
            this.verifyEqual(lhdr.parseSplitNumeric('!originating system'), 2008);
            this.verifyEqual(lhdr.parseSplitString( '%SMS-MI header name space'), 'PETLINK bin address');
            this.verifyEqual(lhdr.parseSplitString( 'name of data file'), 'E:\PETQCDATA\PET_ACQ_550_20170124100253-0.l');
            this.verifyEqual(lhdr.parseSplitString( '%study date (yyyy:mm:dd)'), '2017:01:24');
            this.verifyEqual(lhdr.parseSplitString( '%study time (hh:mm:ss GMT+00:00)'), '16:03:20');
            this.verifyEqual(lhdr.parseSplitNumeric('tracer activity at time of injection (Bq)'), 3.7e+006);
            this.verifyEqual(lhdr.parseSplitNumeric('%energy window lower level (keV) [1]'), 430);
            this.verifyEqual(lhdr.parseSplitString('%segment table'), '{64, 63, 63, 62, 62, 61, 61, 60, 60, 59, 59, 58, 58, 57, 57, 56, 56, 55, 55, 54, 54, 53, 53, 52, 52, 51, 51, 50, 50, 49, 49, 48, 48, 47, 47, 46, 46, 45, 45, 44, 44, 43, 43, 42, 42, 41, 41, 40, 40, 39, 39, 38, 38, 37, 37, 36, 36, 35, 35, 34, 34, 33, 33, 32, 32, 31, 31, 30, 30, 29, 29, 28, 28, 27, 27, 26, 26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 19, 18, 18, 17, 17, 16, 16, 15, 15, 14, 14, 13, 13, 12, 12, 11, 11, 10, 10, 9, 9, 8, 8, 7, 7, 6, 6, 5, 5, 4, 4}');
        end
        function test_mhdrParser(this)
            mhdr = mlsiemens.MhdrParser('fileprefix', 'Motion-LM-00-OP');
            this.verifyEqual(mhdr.parseSplitNumeric('!originating system'), 2008);
            this.verifyEqual(mhdr.parseSplitNumeric('%SMS-MI version number'), 3.4);
            this.verifyEqual(mhdr.parseSplitString( '%data set[1]'), '{30,phantom_gated-OP_000_000.v.hdr,phantom_gated-OP_000_000.v}');
            this.verifyEqual(mhdr.parseSplitString( '%data set[2]'), '{1000030,phantom_gated-OP_001_000.v.hdr,phantom_gated-OP_001_000.v}');
        end
		function test_getInterfileTagValue(this)
            mhdr = fullfile(this.pwd0, this.mhdr0);
            
            this.verifyEqual(this.testObj.getInterfileTagValue(mhdr, '!originating system'), ...
                2008);
            this.verifyEqual(this.testObj.getInterfileTagValue(mhdr, '%SMS-MI header name space'), ...
                'image main header');
            this.verifyEqual(this.testObj.getInterfileTagValue(mhdr, 'data description'), ...
                'image');
            this.verifyEqual(this.testObj.getInterfileTagValue(mhdr, '%study date (yyyy:mm:dd)'), ...
                '2017:01:24');
            this.verifyEqual(this.testObj.getInterfileTagValue(mhdr, 'number of time frames'), ...
                1);
            this.verifyEqual(this.testObj.getInterfileTagValue(mhdr, '%data set [1]'), ...
                '{1000000000,Motion-LM-00-umap-hardware.v.hdr,UNKNOWN}');
        end
        function test_save_hdr(this)
        end
        function test_save_mhdr(this)
            timestr = datestr(now, 'HH:MM:SS');
            this.testObj.save_mhdr('test.mhdr', 1);
            this.testObj.save_mhdr('test.mhdr', 1);
            this.verifyEqual(length(mlsystem.DirTool('test*.mhdr')), 2); % ensure backup created
            p = mlsiemens.MhdrParser.load('test');
            p.parseSplitString('%comment', 'SMS-MI sinogram common attributes');
            p.parseSplitNumeric('!originating system', 2008);
            p.parseSplitString('%study date (yyyy:mm:dd)', datestr(now, 'yyyy:mm:dd'));
            p.parseSplitString('%study time (hh:mm:ss GMT+00:00)', timestr);
            p.parseSplitNumeric('number of time frames', 1);
            p.parseSplitNumeric('%emission data type description [1]', 'prompts'); 
            p.parseSplitNumeric('%data set [0]', '{1,test000.s.hdr,test000.s}');            
        end
	end

 	methods (TestClassSetup)
		function setupSortLMMotionMatlab(this)
 			import mlan.*;
            [~,h] = mlbash('hostname');
            if (lstrfind(h, 'william'))                
                this.pwd0 = this.pwdWilliam;
            else
                this.pwd0 = this.pwdMac;
            end            
 			this.testObj_ = SortLMMotionMatlab('dir0', this.pwd0);
 		end
	end

 	methods (TestMethodSetup)
		function setupSortLMMotionMatlabTest(this)
 			this.testObj = this.testObj_;
 			this.addTeardown(@this.cleanFiles);
            cd(this.pwd0);
 		end
	end

	properties (Access = private)
 		testObj_
 	end

	methods (Access = private)
		function cleanFiles(this)
            pwd0_ = pushd(this.pwd0);
            deleteExisting('test.mhdr');
            deleteExisting('test_backup*.mhdr');
            popd(pwd0_);
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end


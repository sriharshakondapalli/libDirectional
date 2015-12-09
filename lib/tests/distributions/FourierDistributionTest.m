classdef FourierDistributionTest< matlab.unittest.TestCase    
    properties
    end
    
    methods (Static)
        function testFourierConversion(testCase,dist,coeffs,conversion,tolerance)
            xvals=-2*pi:0.01:3*pi;
            fd=FourierDistribution.fromDistribution(dist,coeffs,conversion);
            testCase.verifyEqual(length(fd.a)+length(fd.b),coeffs);
            testCase.verifyEqual(fd.pdf(xvals),dist.pdf(xvals),'AbsTol',tolerance);
        end
    end
    
    methods (Test)
        % Test conversions
        function testVMToFourierId(testCase)
            mu=0.4;
            for kappa=.1:.1:2
                dist=VMDistribution(mu,kappa);
                FourierDistributionTest.testFourierConversion(testCase,dist,101,'identity',1E-8);
            end
        end
        function testVMToFourierSqrt(testCase)
            mu=0.5;
            for kappa=.1:.1:2
                dist=VMDistribution(mu,kappa);
                FourierDistributionTest.testFourierConversion(testCase,dist,101,'sqrt',1E-8);
            end
        end
        function testWNToFourierId(testCase)
            mu=0.8;
            for sigma=.2:.1:2
                dist=WNDistribution(mu,sigma);
                FourierDistributionTest.testFourierConversion(testCase,dist,101,'identity',1E-8);
            end
        end
        function testWNToFourierSqrt(testCase)
            mu=0.9;
            warningSettings=warning('off','Conversion:NoFormulaSqrt');
            for sigma=.2:.1:2
                dist=WNDistribution(mu,sigma);
                FourierDistributionTest.testFourierConversion(testCase,dist,101,'sqrt',1E-8);
            end
            warning(warningSettings);
        end
        function testWCToFourierId(testCase)
            mu=1.2;
            for gamma=.8:.1:3
                dist=WCDistribution(mu,gamma);
                FourierDistributionTest.testFourierConversion(testCase,dist,101,'identity',1E-7);
            end
        end
        function testWCToFourierSqrt(testCase)
            mu=1.3;
            warningSettings=warning('off','Conversion:ApproximationHypergeometric');
            for gamma=.8:.1:3
                dist=WCDistribution(mu,gamma);
                FourierDistributionTest.testFourierConversion(testCase,dist,101,'sqrt',1E-7);
            end
            warning(warningSettings);
        end
        function testWEToFourierId(testCase)
            %Treat differently due to lack of continuity
            warningSettings=warning('off','Normalization:notNormalized');
            for lambda=.1:.1:2
                xvals=-2*pi:0.01:3*pi;
                xvals=xvals(mod(xvals,2*pi)>0.5 & mod(xvals,2*pi)<(2*pi-0.5));
                dist=WEDistribution(lambda);
                fd=FourierDistribution.fromDistribution(dist,1001,'identity');
                testCase.verifyEqual(length(fd.a)+length(fd.b),1001);
                testCase.verifyEqual(fd.pdf(xvals),dist.pdf(xvals),'AbsTol', 5E-3);
            end
            warning(warningSettings);
        end
        function testWEToFourierSqrt(testCase)
            %For sqrt, same applies as to identity
            warningSettings=warning('off','Normalization:notNormalized');
            for lambda=.1:.1:2
                xvals=-2*pi:0.01:3*pi;
                xvals=xvals(mod(xvals,2*pi)>0.5 & mod(xvals,2*pi)<(2*pi-0.5));
                dist=WEDistribution(lambda);
                fd=FourierDistribution.fromDistribution(dist,1001,'sqrt');
                testCase.verifyEqual(length(fd.a)+length(fd.b),1001);
                testCase.verifyEqual(fd.pdf(xvals),dist.pdf(xvals),'AbsTol', 5E-3);
            end
            warning(warningSettings);
        end
        function testWLToFourierId(testCase)
            %Only test parameter combinations that don't result in too
            %abrupt changes in pdf values
            for lambda=0.1:0.2:1
                for kappa=0.1:0.5:4
                    dist=WLDistribution(lambda,kappa);
                    FourierDistributionTest.testFourierConversion(testCase,dist,1001,'identity',1E-3);
                end
            end
        end
        function testWLToFourierSqrt(testCase)
            warningSettings=warning('off','Conversion:NoFormulaSqrt');
            for lambda=0.1:0.2:1
                for kappa=0.1:0.5:4
                    dist=WLDistribution(lambda,kappa);
                    FourierDistributionTest.testFourierConversion(testCase,dist,1001,'sqrt',1E-3);
                end
            end
            warning(warningSettings);
        end
        function testCircularUniformToFourierId(testCase)
            dist=CircularUniformDistribution();
            FourierDistributionTest.testFourierConversion(testCase,dist,101,'identity',1E-8);
        end
        function testCircularUniformToFourierSqrt(testCase)
            dist=CircularUniformDistribution();
            FourierDistributionTest.testFourierConversion(testCase,dist,101,'sqrt',1E-8);
        end
        function testGCMToFourierId(testCase)
            vm=VMDistribution(1,2);
            wn=WNDistribution(2,1);
            dist=CircularMixture({vm,wn},[0.3,0.7]);
            FourierDistributionTest.testFourierConversion(testCase,dist,101,'identity',1E-8);
        end
        function testGCMToFourierSqrt(testCase)
            warningSettings=warning('off','Conversion:NoFormulaSqrt');
            vm=VMDistribution(1,2);
            wn=WNDistribution(2,1);
            dist=CircularMixture({vm,wn},[0.3,0.7]);
            FourierDistributionTest.testFourierConversion(testCase,dist,101,'sqrt',1E-8);
            warning(warningSettings);
        end
        function testCCDToFourierId(testCase)
            warningSettings=warning('off','Conversion:NoFormula');
            vm=VMDistribution(1,2);
            dist=CustomCircularDistribution(@(x)vm.pdf(x));
            FourierDistributionTest.testFourierConversion(testCase,dist,101,'identity',1E-8);
            warning(warningSettings);
        end
        function testCCDToFourierSqrt(testCase)
            warningSettings=warning('off','Conversion:NoFormula');
            vm=VMDistribution(1,2);
            dist=CustomCircularDistribution(@(x)vm.pdf(x));
            FourierDistributionTest.testFourierConversion(testCase,dist,101,'sqrt',1E-8);
            warning(warningSettings);
        end
        % Test coefficient conversions
        function testCoefficientConversion1(testCase)
            a=[1/pi,4,3,2,1];
            b=[4,3,2,1];
            fd1=FourierDistribution(a,b,'identity');
            fd2=FourierDistribution.fromComplex(fd1.c,'identity');
            testCase.verifyEqual(fd2.a,fd1.a,'AbsTol',1E-10)
            testCase.verifyEqual(fd2.b,fd1.b,'AbsTol',1E-10)
        end
        function testCoefficientConversion2(testCase)
            kappa=2;
            fd1=FourierDistribution.fromDistribution(VMDistribution(0,kappa),101,'identity');
            fd2=FourierDistribution.fromComplex(fd1.c,'identity');
            testCase.verifyEqual(fd2.a,fd1.a,'AbsTol',1E-10)
            testCase.verifyEqual(fd2.b,fd1.b,'AbsTol',1E-10)
        end
        function testFromFunction(testCase)
            xvals=-2*pi:0.01:3*pi;
            for kappa=0.1:0.3:4
                vm=VMDistribution(3,kappa);
                fd=FourierDistribution.fromFunction(@(x)vm.pdf(x),101,'sqrt');
                testCase.verifyEqual(fd.pdf(xvals),vm.pdf(xvals),'AbsTol',1E-8);
            end
        end
        function testFromFunctionValues(testCase)
            xvals=-2*pi:0.01:3*pi;
            vm=VMDistribution(3,1);
            fvals=vm.pdf(linspace(0,2*pi,100));
            fvals(end)=[];
            fd1=FourierDistribution.fromFunctionValues(fvals,99,'sqrt');
            fvals=vm.pdf(linspace(0,2*pi,101));
            fvals(end)=[];
            fd2=FourierDistribution.fromFunctionValues(fvals,99,'sqrt');
            testCase.verifyEqual(fd1.pdf(xvals),vm.pdf(xvals),'AbsTol',1E-8);
            testCase.verifyEqual(fd2.pdf(xvals),vm.pdf(xvals),'AbsTol',1E-8);
        end
        % Test prediction and filter steps
        function testFourierRootFilterVM(testCase)
            xvals=-2*pi:0.01:3*pi;
            for kappa1=0.1:0.3:4
                for kappa2=0.1:0.3:4
                    dist1=VMDistribution(0,kappa1);
                    dist2=VMDistribution(0,kappa2);
                    f1=FourierDistribution.fromDistribution(dist1,101,'sqrt');
                    f2=FourierDistribution.fromDistribution(dist2,101,'sqrt');
                    fFiltered=f1.multiply(f2);
                    distResult=dist1.multiply(dist2);
                    testCase.verifyEqual(fFiltered.pdf(xvals),distResult.pdf(xvals),'AbsTol',1E-8);
                end
            end
        end
        function testFourierRootPredictionWN(testCase)
            warningSettings=warning('off','Conversion:NoFormulaSqrt');
            xvals=-2*pi:0.01:3*pi;
            for sigma1=0.1:0.3:4
                for sigma2=0.1:0.3:4
                    dist1=WNDistribution(0,sigma1);
                    dist2=WNDistribution(0,sigma2);
                    f1=FourierDistribution.fromDistribution(dist1,101,'sqrt');
                    f2=FourierDistribution.fromDistribution(dist2,101,'sqrt');
                    fPredicted=f1.convolve(f2,101);
                    distResult=dist1.convolve(dist2);
                    testCase.verifyEqual(fPredicted.pdf(xvals),distResult.pdf(xvals),'AbsTol',1E-8);
                end
            end
            warning(warningSettings);
        end
        function testMomentsFourierRootPredictionVM(testCase)
            for kappa1=0.1:0.3:4
                for kappa2=0.1:0.3:4
                    vm1=VMDistribution(0,kappa1);
                    vm2=VMDistribution(0,kappa2);
                    vmRes=vm1.convolve(vm2);
                    f1=FourierDistribution.fromDistribution(vm1,101,'sqrt');
                    f2=FourierDistribution.fromDistribution(vm2,101,'sqrt');
                    fPredicted=f1.convolve(f2,101);
                    testCase.verifyEqual(fPredicted.trigonometricMoment(1),vmRes.trigonometricMoment(1),'AbsTol',1E-8);
                end
            end
        end
        function testErrorsPredictAndFilter(testCase)
            warningSettings=warning('off','Normalization:cannotTest');
            fd1=FourierDistribution.fromDistribution(VMDistribution(0,1),101,'sqrt');
            fd2=FourierDistribution.fromDistribution(VMDistribution(0,1),101,'identity');
            testCase.verifyError(@()fd1.multiply(fd2),'Multiply:differentTransformations');
            testCase.verifyError(@()fd1.convolve(fd2),'Convolve:differentTransformations');
            fd3=fd2.transformViaCoefficients('square',101);
            testCase.verifyError(@()fd3.multiply(fd3),'Multiply:unsupportedTransformation');
            testCase.verifyError(@()fd3.convolve(fd3),'Convolve:unsupportedTransformation');
            warning(warningSettings);
        end
        % Test transformations
        function testTransformViaFFT(testCase)
            xvals=-2*pi:0.01:3*pi;
            for kappa=0.1:0.3:4
                vm=VMDistribution(3,kappa);
                fd1=FourierDistribution.fromDistribution(vm,101,'identity');
                fd2=fd1.transformViaFFT('sqrt',101);
                testCase.verifyEqual(fd2.pdf(xvals),vm.pdf(xvals),'AbsTol',1E-8);
            end
        end
        function testTransformViaVM(testCase)
            xvals=-2*pi:0.01:3*pi;
            for sigma=0.1:0.1:4
                wntmp=WNDistribution(1,sigma);
                fd=FourierDistribution.fromDistribution(wntmp,101,'identity');
                vm=wntmp.toVM;
                fdtrans=fd.transformViaVM('sqrt',101);
                testCase.verifyEqual(fdtrans.pdf(xvals),vm.pdf(xvals),'AbsTol',1E-8);
            end
        end
        function testSquaring(testCase)
            xvals=-2*pi:0.01:3*pi;
            for kappa=0.1:0.3:4
                dist=VMDistribution(0,kappa);
                fd1=FourierDistribution.fromDistribution(dist,101,'sqrt');
                fd2=fd1.transformViaCoefficients('square',101);
                testCase.verifyEqual(fd2.pdf(xvals),dist.pdf(xvals),'AbsTol',1E-8);
            end
        end
        function testErrorRepeatedTransformation(testCase)
            vm=VMDistribution(3,1);
            fd1=FourierDistribution.fromFunction(@(x)vm.pdf(x),9,'identity');
            fd2=fd1.transformViaFFT('sqrt',9);
            testCase.verifyError(@()fd2.transformViaFFT('sqrt',9),'Transformation:alreadyTransformed')
        end
        function testSquareAfterSqrt(testCase)
            vm=VMDistribution(3,1);
            fd1=FourierDistribution.fromFunction(@(x)vm.pdf(x),101,'identity');
            fd2=fd1.transformViaFFT('sqrt',101);
            fd3=fd2.transformViaCoefficients('square',101);
            testCase.verifyEqual(fd3.transformation,'identity');
            testCase.verifyEqual(fd3.a,fd1.a,'AbsTol',1E-8);
            testCase.verifyEqual(fd3.b,fd1.b,'AbsTol',1E-8);
        end
        function testCustomTransformation(testCase)
            xvals=-2*pi:0.01:3*pi;
            vm=VMDistribution(3,1);
            fvals=vm.pdf(linspace(0,2*pi,100)).^3;
            fvals(end)=[];
            warningSettings=warning('off','Normalization:cannotTest');
            fd=FourierDistribution.fromFunctionValues(fvals,99,'custom');
            warning(warningSettings);
            testCase.verifyEqual(fd.value(xvals),vm.pdf(xvals).^3,'AbsTol',1E-8);
        end
        function testTransformToMoreCoeffs(testCase)
            vm=VMDistribution(3,1);
            fdSqrt=FourierDistribution.fromDistribution(vm,1001,'sqrt');
            fdId=FourierDistribution.fromDistribution(vm,101,'identity');
            warningSettings=warning('off','Truncate:TooFewCoefficients');
            fdIdSqrt=fdId.transformViaFFT('sqrt',1001);
            warning(warningSettings);
            testCase.verifyEqual(length(fdIdSqrt.a)+length(fdIdSqrt.b),1001);
            testCase.verifyEqual(fdIdSqrt.a,fdSqrt.a,'AbsTol',1E-8);
            testCase.verifyEqual(fdIdSqrt.b,fdSqrt.b,'AbsTol',1E-8);
        end
        function testTransformToLessCoeffs(testCase)
            %case is easy enough to work with less coeffs
            vm=VMDistribution(3,1);
            fdSqrt=FourierDistribution.fromDistribution(vm,101,'sqrt');
            fdId=FourierDistribution.fromDistribution(vm,1001,'identity');
            fdIdSqrt=fdId.transformViaFFT('sqrt',101);
            testCase.verifyEqual(length(fdIdSqrt.a)+length(fdIdSqrt.b),101,'AbsTol',1E-8);
            testCase.verifyEqual(fdIdSqrt.a,fdSqrt.a,'AbsTol',1E-8);
            testCase.verifyEqual(fdIdSqrt.b,fdSqrt.b,'AbsTol',1E-8);
        end
        % CDF tests
        function testCdfIdentityStartZero(testCase)
            fd=FourierDistribution.fromDistribution(VMDistribution(1,3),101,'identity');
            xvals=0:0.01:2*pi;
            intValsNumerically=arrayfun(@(xend)integral(@(x)fd.pdf(x),0,xend),xvals);
            testCase.verifyEqual(fd.cdf(xvals,0),intValsNumerically,'AbsTol',1E-8);
        end
        function testCdfSqrtStartZero(testCase)
            fd=FourierDistribution.fromDistribution(VMDistribution(1,3),101,'sqrt');
            xvals=0:0.01:2*pi;
            intValsNumerically=arrayfun(@(xend)integral(@(x)fd.pdf(x),0,xend),xvals);
            testCase.verifyEqual(fd.cdf(xvals,0),intValsNumerically,'AbsTol',1E-8);
        end
        function testCdfIdentityStartNonzero(testCase)
            fd=FourierDistribution.fromDistribution(VMDistribution(1,3),101,'identity');
            xvals=0:0.01:2*pi;
            startingPoint=1;
            intValsNumerically=[arrayfun(@(xend)integral(@(x)fd.pdf(x),0,xend)+integral(@(x)fd.pdf(x),startingPoint,2*pi),xvals(xvals<startingPoint)),...
                arrayfun(@(xend)integral(@(x)fd.pdf(x),startingPoint,xend),xvals(xvals>=startingPoint))];
            testCase.verifyEqual(fd.cdf(xvals,startingPoint),intValsNumerically,'AbsTol',1E-8);
        end
        %other tests
        function testTruncation(testCase)
            vm=VMDistribution(3,1);
            fd1=FourierDistribution.fromDistribution(vm,101,'sqrt');
            testCase.verifyWarning(@()fd1.truncate(1001),'Truncate:TooFewCoefficients');
            warningSettings=warning('off','Truncate:TooFewCoefficients');
            fd2=fd1.truncate(1001);
            warning(warningSettings);
            testCase.verifyEqual(length(fd2.a)+length(fd2.b),1001,'AbsTol',1E-8);
            fd3=fd2.truncate(51);
            testCase.verifyEqual(length(fd3.a)+length(fd3.b),51,'AbsTol',1E-8);
        end
        function testMoments(testCase)
            vm=VMDistribution(2,1);
            fd1=FourierDistribution.fromDistribution(vm,15,'identity');
            fd2=FourierDistribution.fromDistribution(vm,15,'sqrt');
            for i=-2:3
                vmMoment=vm.trigonometricMoment(i);
                testCase.verifyEqual(fd1.trigonometricMoment(i),vmMoment,'AbsTol',1E-6);
                testCase.verifyEqual(fd1.trigonometricMomentNumerical(i),vmMoment,'AbsTol',1E-6);
                testCase.verifyEqual(fd2.trigonometricMoment(i),vmMoment,'AbsTol',1E-6);
                testCase.verifyEqual(fd2.trigonometricMomentNumerical(i),vmMoment,'AbsTol',1E-6);
            end
            testCase.verifyEqual(fd1.trigonometricMoment(16),0);
            testCase.verifyEqual(fd2.trigonometricMoment(30),0);
        end
        function testNormalizationAfterTruncation(testCase)
            dist=VMDistribution(0,5);
            fdSqrt=FourierDistribution.fromDistribution(dist,1001,'sqrt');
            testCase.verifyEqual(integral(@(x)fdSqrt.pdf(x),0,2*pi),1,'RelTol',1E-4);
            % Perform truncation without normalization
            fdSqrtManuallyTruncated=fdSqrt;
            fdSqrtManuallyTruncated.a=fdSqrt.a(1:3);
            fdSqrtManuallyTruncated.b=fdSqrt.b(1:2);
            % Verify that this case requires normalization after truncation
            testCase.verifyTrue(abs(integral(@(x)fdSqrtManuallyTruncated.pdf(x),0,2*pi)-1)>=0.01);
            fdSqrtTrunc=fdSqrt.truncate(7);
            % Verify that use of .truncate results in a normalized density
            testCase.verifyEqual(integral(@(x)fdSqrtTrunc.pdf(x),0,2*pi),1,'RelTol',1E-4);
        end
    end
end

%     -----------------------------------------------------------------
%
%                              Ex7_5.m
%
%  this file demonstrates example 7-5.
%
%                          companion code for
%             fundamentals of astrodynamics and applications
%                                 2007
%                            by david vallado
%
%     (w) 719-573-2600, email dvallado@agi.com
%
%     *****************************************************************
%
%  current :
%            30 mar 07  david vallado
%                         original
%  changes :
%            13 feb 07  david vallado
%                         original baseline
%
%     *****************************************************************
    fid = 1;

    fprintf(1,'\n-------- lambertu test book pg 467 \n' );
    ro = [ 2.500000,    0.000000 ,   0.000000]*6378.137;
    r  = [ 1.9151111,   1.6069690,   0.000000]*6378.137;
    dtsec = 76.0*60.0;
    dm = 's';
    overrev = 0;
    fprintf(1,' ro %16.8f%16.8f%16.8f\n',ro );
    fprintf(1,' r  %16.8f%16.8f%16.8f\n',r );
    [vo,v,errorl] = lambertu ( ro,r, dm,overrev, dtsec,fid );
    fprintf(1,' vo %16.8f%16.8f%16.8f\n',vo );
    fprintf(1,' v  %16.8f%16.8f%16.8f\n',v );

    
    
    fprintf(1,'\n-------- lambertb test book pg 467 \n' );
    ro = [ 2.500000    0.000000    0.000000]*6378.137;
    r  = [ 1.9151111   1.6069690   0.000000]*6378.137;
    dtsec = 76.0*60.0;
    dm = 's';
    overrev = 0;
    fprintf(1,' ro %16.8f%16.8f%16.8f\n',ro );
    fprintf(1,' r  %16.8f%16.8f%16.8f\n',r );
    [vo,v,errorl] = lambertb ( ro,r, dm,overrev, dtsec );
    fprintf(1,' vo %16.8f%16.8f%16.8f\n',vo );
    fprintf(1,' v  %16.8f%16.8f%16.8f\n',v );

    
    pause;

    fprintf(1,'\n-------- lambertb test ben joseph \n' );
    ro = [ 6822.88933   -5147.86167    -454.39488];
    r  = [ -4960.67860   10585.2504   927.1937739];
    dtsec = 4976.002;
    dm = 's';
    overrev = 0;
    fprintf(1,' ro %16.8f%16.8f%16.8f\n',ro );
    fprintf(1,' r  %16.8f%16.8f%16.8f\n',r );
    [vo,v,errorl] = lambertb ( ro,r, dm,overrev, dtsec );
    fprintf(1,' vo %16.8f%16.8f%16.8f\n',vo );
    fprintf(1,' v  %16.8f%16.8f%16.8f\n',v );
    
    pause;

    fprintf(1,'\n-------- lambertu test giuseppe \n' );
    mu         = 398600.4418;      % km3/s2
    re = 6378.137;
    velkmps = sqrt(mu / 6378.137);
    rad = 180.0/pi;

    ro = [ 0.500000,   0.600000,   0.700000]*re;
    r  = [ 0.000000,   1.000000,   0.000000]*re;
    dtsec = 779.999;
    dm = 's';
    overrev = 0;
    fprintf(1,' ro %16.8f%16.8f%16.8f\n',ro );
    fprintf(1,' r  %16.8f%16.8f%16.8f\n',r );
    [vo,v,errorl] = lambertu ( ro,r, dm,overrev, dtsec,fid );
    fprintf(1,' vo %16.8f%16.8f%16.8f\n',vo );
    fprintf(1,' v  %16.8f%16.8f%16.8f\n',v );
 [p,a,ecc,incl,omega,argp,nu,m,arglat,truelon,lonper ] = rv2coeh (ro,vo, re, mu);
 fprintf(1,'ans coes %11.4f%11.4f%13.9f%13.7f%11.5f%11.5f%11.5f%11.5f\n',...
        p,a,ecc,incl*rad,omega*rad,argp*rad,nu*rad,m*rad );
 [p,a,ecc,incl,omega,argp,nu,m,arglat,truelon,lonper ] = rv2coeh (r,v, re, mu);
 fprintf(1,'ans coes %11.4f%11.4f%13.9f%13.7f%11.5f%11.5f%11.5f%11.5f\n',...
        p,a,ecc,incl*rad,omega*rad,argp*rad,nu*rad,m*rad );

    [vo,v,errorl] = lambertb ( ro,r, 's',overrev, dtsec );
    fprintf(1,' vo %16.8f%16.8f%16.8f\n',vo );
    fprintf(1,' v  %16.8f%16.8f%16.8f\n',v );
 [p,a,ecc,incl,omega,argp,nu,m,arglat,truelon,lonper ] = rv2coeh (ro,vo, re, mu);
 fprintf(1,'ans coes %11.4f%11.4f%13.9f%13.7f%11.5f%11.5f%11.5f%11.5f\n',...
        p,a,ecc,incl*rad,omega*rad,argp*rad,nu*rad,m*rad );
 [p,a,ecc,incl,omega,argp,nu,m,arglat,truelon,lonper ] = rv2coeh (r,v, re, mu);
 fprintf(1,'ans coes %11.4f%11.4f%13.9f%13.7f%11.5f%11.5f%11.5f%11.5f\n',...
        p,a,ecc,incl*rad,omega*rad,argp*rad,nu*rad,m*rad );
    


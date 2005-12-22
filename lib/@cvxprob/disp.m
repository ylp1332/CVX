function disp( prob, prefix )

if nargin < 2, prefix = ''; end

global cvx___
p = cvx___.problems( index( prob ) );

if isempty( p.variables ),
    nvars = 0;
else,    
    nvars = length( fieldnames( p.variables ) );
end
if isempty( p.duals ),
    nduls = 0;
else,
    nduls = length( fieldnames( p.duals ) );
end
neqns = length( p.equalities );
nslck = length( p.cones );
if isempty( p.name ) | strcmp( p.name, 'cvx_' ),
    nm = '';
else,
    nm = [ p.name, ': ' ];
end

if nvars + neqns + nslck + nduls == 0,
    disp( [ prefix, nm, 'cvx problem object' ] );
else,
    switch prod( size( p.objective ) ),
        case 0,
            tp = 'feasibility';
        case 1,
            tp = [ p.direction(1:end-1), 'ation' ];
        otherwise,
            sz = sprintf( '%dx', size( p.objective ) );
            tp = [ p.direction(1:end-1), 'ation' ];
            tp = [ sz(1:end-1), '-objective ', tp ];
    end
    disp( [ prefix, nm, 'cvx ', tp, ' problem' ] );
    disp( sprintf( '%s   %d variables (%d free), %d equalities', prefix, length( p.reserved ) - 1, sum( 1 - p.reserved ), size( p.equalities, 1 ) ) );
    if nvars > 0,
        disp( [ prefix, 'variables: ' ] );
        [ vnam, vsiz ] = dispvar( p.variables, '' );
        vnam = strvcat( vnam );
        vsiz = strvcat( vsiz );
        for k = 1 : size( vnam ),
            disp( [ prefix, '   ', vnam( k, : ), '  ', vsiz( k, : ) ] );
        end
    end
    if nduls > 0,
        disp( [ prefix, 'dual variables: ' ] );
        [ vnam, vsiz ] = dispvar( p.duals, '' );
        vnam = strvcat( vnam );
        vsiz = strvcat( vsiz );
        for k = 1 : size( vnam ),
            disp( [ prefix, '   ', vnam( k, : ), '  ', vsiz( k, : ) ] );
        end
    end
    if nslck > 0 | neqns > 0,
        disp( [ prefix, 'constraints:' ] );
        prefix = [ prefix, '   ' ];
        if neqns > 0,
            if neqns > 1, plural = 's'; else, plural = ''; end
            disp( sprintf( '%s%d equality constraint%s', prefix, neqns, plural ) );
        end
        for k = 1 : length( p.cones ),
            if isequal( p.cones( k ).type, 'nonnegative' ),
                ncones = 1;
                csize = prod( size( p.cones( k ).indices ) );
            else,
                [ csize, ncones ] = size( p.cones( k ).indices );
            end
            if ncones == 1, plural = ''; else, plural = 's'; end
            disp( sprintf( '%s%d order-%d %s cone%s', prefix, ncones, csize, p.cones( k ).type, plural ) );
        end
    end
end

function [ names, sizes ] = dispvar( v, name, isdual )
if nargin < 3, isdual = false; end

switch class( v ),
    case 'struct',
        fn = fieldnames( v );
        if ~isempty( name ), name( end + 1 ) = '.'; end
        names = {}; sizes = {};
        for k = 1 : length( fn ),
            [ name2, size2 ] = dispvar( subsref(v,struct('type','.','subs',fn{k})), [ name, fn{k} ], isdual );
            names( end + 1 : end + length( name2 ) ) = name2;
            sizes( end + 1 : end + length( size2 ) ) = size2;
            if k == 1 & ~isempty( name ), name( 1 : end - 1 ) = ' '; end
        end
    case 'cell',
        nsiz = size( v );
        ntot = prod( nsiz );
        ndxs = cell( 1, length( nsiz ) - ( nsiz(end) == 1 ) );
        [ ndxs{:} ] = ind2sub( nsiz, 1 : ntot );
        ndxs = vertcat( ndxs{:} );
        names = {}; sizes = {};
        for k = 1 : ntot,
            temp = sprintf( '%d,', ndxs(:,k) );
            [ name2, size2 ] = dispvar( v{k}, sprintf( '%s{%s}', name, temp(1:end-1) ), isdual );
            names( end + 1 : end + length( name2 ) ) = name2;
            sizes( end + 1 : end + length( size2 ) ) = size2;
            if k == 1, name( 1 : end ) = ' '; end
        end
    otherwise,
        names = { name };
        sizes = { [ '(', type( v ), ')' ] };
end

% Copyright 2005 Michael C. Grant and Stephen P. Boyd. 
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.

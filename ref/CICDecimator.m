function [y] = CICDecimator(s, varargin)
    %% check inputs
    ip = inputParser;
    addParameter(ip,'B', [], @(x) validateattributes(x, {'numeric'},{'positive','integer'})); 
    addParameter(ip,'N',  1, @(x) validateattributes(x, {'numeric'},{'positive','integer'}));
    addParameter(ip,'M',  1, @(x) validateattributes(x, {'numeric'},{'positive','integer'}));
    addParameter(ip,'R',  8, @(x) validateattributes(x, {'numeric'},{'positive','integer'}));
    addParameter(ip,'decimOff', false, @(x) validateattributes(x, {'logical'},{}));
    addParameter(ip,'compatibilityMode','dsp',@(x) any(strcmp(x,["dsp","hw","stream"])));
     
    parse(ip,varargin{:});
    p = ip.Results;
    
    if ~isempty(p.B)
        B_growth = p.N*log2(p.R*p.M); % register growth due to amplification
        if p.B(1) + B_growth > 64
           error('Bit size is too large to be simulated using int64'); 
        end
        B_in  = p.B + B_growth;
        B_out = p.B;
        B = [repmat(B_in, 2*p.N-1, 1);B_out]; % all stages but the last have same input width
        A = 2.^(B-1);
        C = 2.^(B);
    end
%     s = int64(s); % make sure we have integers
    
    %% Block version (optimized for Matlab)

    % integrator stages, i.e. int(:, end) is the output of last integrator
    int = zeros(length(s), p.N+1);
    int(:, 1) = s(:);
    for i=1:p.N
       int(:, i+1) = cumsum(int(:, i));
%        int(:, i+1) = mod(int(:, i+1) + A(i), C(i)) - A(i); % quantize
    end
    
    % downsampling
    if p.decimOff
        ds = int(1:1:end, end);
        diff = zeros(length(s), p.N+1);
    else
        % start downsampling after p.R/2 integrator steps (pipeline delay)
        if strcmp(p.compatibilityMode, 'dsp')
            ds = int(p.R-p.N+1:p.R:end, end);
        elseif strcmp(p.compatibilityMode, 'hw')
            ds = int(p.R:p.R:end, end);
        end
        diff = zeros(ceil(length(s)/p.R), p.N+1);
    end

    % comb stages, i.e. diff(:, end) is the output of last comb
    diff(:, 1) = ds;
    for i=1:p.N
        if p.decimOff
            diff_dly = [zeros(p.R*p.M, 1); diff(1:end-p.R*p.M, i)];
        else
            diff_dly = [zeros(p.M, 1); diff(1:end-p.M, i)];
        end
        diff(:, i+1) = diff(:, i) - diff_dly;
    end
    y = diff(:, end);
%     y = mod(diff(:, end) - 2^(B_in-1), 2^B_in) + 2^(B_in-1);
%     y = y / 2^(B_in-B_out);


    %% Streaming version, based on [2] (see misc/README.md)
%     ints = zeros(1,p.N);
%     if p.decimOff
%         comb = zeros(p.N,p.R-1+p.M+2);
%     else
%         comb = zeros(p.N,p.M+2);
%     end
%     l = 1;
%     a = zeros(ceil(length(s)/p.R), 1);
%     for i=1:length(s)
%         ints = [s(i) ints(1:end-1)] + ints;
%         if (mod(i,p.R) == 0 || p.decimOff)
%             comb = [[ints(end); comb(1:end-1, end)] comb(:, 1:end-1)];
%             comb(:, end) = comb(:, 1) - comb(:, end-1);
%             a(l) = comb(end,end);
%             l=l+1;
%         end
%     end
%     y = a;
end
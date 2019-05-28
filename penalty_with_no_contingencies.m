function csigma = penalty_with_no_contingencies(sigmaPplusi, sigmaPminusi, sigmaQplusi, sigmaQminusi, sigmase, sigmafe, lambdaPn, lambdaQn, lambdaen, limits)

    % equation 6
    
    csigma = 0;
%     
    csigma_temp = 0;
    for i = 1:1:size(sigmaPplusi,1)
        limit = sum(sigmaPplusi(i) >= limits(1,:)) +1;
        lambda = lambdaPn(limit);
        csigma_temp = csigma_temp + sigmaPplusi(i)*lambda;
    end
    csigma = csigma + csigma_temp;
    
    csigma_temp = 0;
    for i=1:1:size(sigmaPminusi,1)
        limit = sum(sigmaPminusi(i) >= limits(1,:)) +1;
        lambda = lambdaPn(limit);
        csigma_temp = csigma_temp + sigmaPminusi(i)*lambda;
    end
    csigma = csigma + csigma_temp;
    
    csigma_temp = 0;
    for i=1:1:size(sigmaQplusi,1)
        limit = sum(sigmaQplusi(i) >= limits(2,:)) +1;
        lambda = lambdaQn(limit);
        csigma_temp = csigma_temp + sigmaQplusi(i)*lambda;
    end
    csigma = csigma + csigma_temp;
    
    csigma_temp = 0;
    for i=1:1:size(sigmaQminusi,1)
        limit = sum(sigmaQminusi(i) >= limits(2,:)) +1;
        lambda = lambdaQn(limit);
        csigma_temp = csigma_temp + sigmaQminusi(i)*lambda;
    end
    csigma = csigma + csigma_temp;

    csigma_temp = 0;
    for i=1:1:size(sigmase,1)
        limit = sum(sigmase(i) >= limits(3,:)) +1;
        lambda = lambdaen(limit);
        csigma_temp = csigma_temp + sigmase(i)*lambda;
    end
    csigma = csigma + csigma_temp;
    
    csigma_temp = 0;
    for i=1:1:size(sigmafe,1)
        limit = sum(sigmafe(i) >= limits(3,:)) +1;
        lambda = lambdaen(limit);
        csigma_temp = csigma_temp + sigmafe(i)*lambda;
    end
    csigma = csigma + csigma_temp;
    
end

function [sigmaPplusi, sigmaPminusi, sigmaQplusi, sigmaQminusi] = bus_power_balance_constraints(bus_info, pg, qg, pLi, qLi, gFSi, bFSi, bCSi, v, poe, pde, pof, pdf, qoe, qde, qof, qdf, no_of_buses)
    
    left = zeros(no_of_buses, 1);
    leftQ = zeros(no_of_buses, 1);
    %eqn (46) page 23
    for i=1:1:no_of_buses
        generator_list = bus_info(i).generator_list;
        origin_list = bus_info(i).origin_list;
        destination_list = bus_info(i).destination_list;
        transformer_origin_list = bus_info(i).transformer_origin_list;
        transformer_destination_list = bus_info(i).transformer_destination_list;
        
        for j=1:1:size(generator_list,2)
            left(i) = left(i) + pg(generator_list(j));
            leftQ(i) = leftQ(i) + qg(generator_list(j));
        end
        for j=1:1:size(origin_list,2)
            left(i) = left(i) - poe(origin_list(j));
            leftQ(i) = leftQ(i) - qoe(origin_list(j));
        end
        for j=1:1:size(destination_list,2)
            left(i) = left(i) - pde(destination_list(j));
            leftQ(i) = leftQ(i) - qde(destination_list(j));  
        end
        for j=1:1:size(transformer_origin_list,2)
            left(i) = left(i) - pof(transformer_origin_list(j));
            leftQ(i) = leftQ(i) - qof(transformer_origin_list(j));
        end
        for j=1:1:size(transformer_destination_list,2)
            left(i) = left(i) - pdf(transformer_destination_list(j));
            leftQ(i) = leftQ(i) - qdf(transformer_destination_list(j));
        end
    end
	left = left - pLi;
	left = left - gFSi.*v.*v;
    leftQ = leftQ - qLi;
    leftQ = leftQ - (-bFSi-bCSi).*v.*v;
    
    sigmaPplusi = left;
    sigmaPminusi = left;
    sigmaPplusi(sigmaPplusi<0) = 0; 
    sigmaPminusi(sigmaPminusi>0) = 0;
    sigmaPminusi = sigmaPminusi * (-1);
    
    sigmaQplusi = leftQ;
    sigmaQminusi = leftQ;
    sigmaQplusi(sigmaQplusi<0) = 0;
    sigmaQminusi(sigmaQminusi>0) = 0;
    sigmaQminusi = sigmaQminusi * (-1);
end
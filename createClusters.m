function [clusters, bus_to_cluster, branches_list] = createClusters(branch_data_GO, transformer_data_GO)


%*************Data intialization******************************************%

branches_connections = [branch_data_GO(:,1:2); transformer_data_GO(:,1:2)];
R = [branch_data_GO(:,3); transformer_data_GO(:,6)];
X = [branch_data_GO(:,4); transformer_data_GO(:,7)];
impedance_ = sqrt(R.^2 + X.^2);
%key_set = branches_connections;
%value_set = impedance_; 
impedance = containers.Map(mat2str(sort(branches_connections(1,:))), impedance_(1));
for i=2:size(branches_connections,2)
    impedance(mat2str(sort(branches_connections(i,:)))) = impedance_(i);
end
branches_list = unique(branches_connections);

M = containers.Map('KeyType','int64','ValueType','any');
for i=1:length(branches_list)
    list = [];
    list(1) = branches_list(i); 
    neigbours_indices1 = find(branches_connections(:,1)== branches_list(i));
    if(~isempty(neigbours_indices1))
        n_neighbores = length(neigbours_indices1);
        list(2:n_neighbores+1) = branches_connections(neigbours_indices1,2);
    end
    n_list = length(list);
    neigbours_indices2 = find(branches_connections(:,2)== branches_list(i));
    if(~isempty(neigbours_indices2))
        n_neighbores = length(neigbours_indices2);
        list(n_list+1:n_neighbores+n_list) = branches_connections(neigbours_indices2,1);
    end
    M(branches_list(i)) = sort(list);
end

groups_members = containers.Map('KeyType','int64','ValueType','any');
inserted = containers.Map('KeyType','int64','ValueType','int64');
for i=1:length(M)-1
    for j=i+1:length(M)
        common_list = intersect(M(branches_list(i)),M(branches_list(j)));
        if isequal(common_list, M(branches_list(i)))
            if ~isKey(groups_members,branches_list(j))
                groups_members(branches_list(j)) = []; 
            end
            if ~isKey(inserted,branches_list(i))
                groups_members(branches_list(j)) = [groups_members(branches_list(j)), branches_list(i)]; 
                inserted(branches_list(i))= branches_list(j);
            else
               if(isKey(impedance,mat2str(sort([branches_list(i), branches_list(j)]))))
                   if(impedance(mat2str(sort([branches_list(i), branches_list(j)])))< ...
                      impedance(mat2str(sort([branches_list(i), inserted(branches_list(i))]))))
                        groups_members(branches_list(j)) = [groups_members(branches_list(j)), branches_list(i)]; 
                        previous_group = groups_members(inserted(branches_list(i)));
                        previous_group(previous_group~=branches_list(i))=[];
                        groups_members(inserted(branches_list(i))) = previous_group;
                        inserted(branches_list(i))= branches_list(j);
                   end
               end
            end
        elseif isequal(common_list, M(branches_list(j)))
            if ~isKey(groups_members,branches_list(i))
                groups_members(branches_list(i)) = []; 
            end
            if ~isKey(inserted,branches_list(j))
                groups_members(branches_list(i)) = [groups_members(branches_list(i)), branches_list(j)]; 
                inserted(branches_list(j))= branches_list(i);
            else
                if(isKey(impedance,mat2str(sort([branches_list(j), branches_list(i)]))))
                   if(impedance(mat2str(sort([branches_list(j), branches_list(i)])))< ...
                      impedance(mat2str(sort([branches_list(j), inserted(branches_list(j))]))))
                        groups_members(branches_list(i)) = [groups_members(branches_list(i)), branches_list(j)]; 
                        previous_group = groups_members(inserted(branches_list(j)));
                        previous_group(previous_group~=branches_list(j))=[];
                        groups_members(inserted(branches_list(j))) = previous_group;
                        inserted(branches_list(j))= branches_list(i);
                   end
               end
                
            end
        end
     end
end
key_set =keys(groups_members); 
for i=1:length(groups_members)
    k = cell2mat(key_set(i));
    if(isempty(groups_members(k)))
        remove(groups_members,k);
    end
end

group_lead =keys(groups_members); 
including_buses = [];
considered_buses = [];
for i=1:length(groups_members)
    k = cell2mat(group_lead(i));
    including_buses = [including_buses, M(k)];
    considered_buses = [considered_buses, k, groups_members(k)];
end
including_buses = unique(including_buses);
not_including_buses = setdiff(branches_list,including_buses);
count_not_including_buses=length(not_including_buses);
j=count_not_including_buses;
not_considered = ones(count_not_including_buses,1); 
for i=1:length(M)
    if ~(ismember(branches_list(i),considered_buses))
        for j=1:count_not_including_buses
            if(ismember(not_including_buses(j),M(branches_list(i))) && not_considered(j))
                if ~(isKey(groups_members,branches_list(i)))
                    groups_members(branches_list(i))=not_including_buses(j);
                else
                    groups_members(branches_list(i))=[groups_members(branches_list(i)), not_including_buses(j)];
                end
                not_considered(j)=0;
            end
        end
    end
end

group_lead =keys(groups_members); 
including_buses = [];
considered_buses = [];
clusters = containers.Map('KeyType','int64','ValueType','any');
count = 1;
for i=1:length(groups_members)
    k = cell2mat(group_lead(i));
    including_buses = [including_buses, M(k)];
    clusters(count) =  M(k);
    count = count+1;
end
including_buses = unique(including_buses);
not_including_buses = setdiff(branches_list,including_buses);

bus_to_cluster = containers.Map('KeyType','int64','ValueType','any');
for i=1:length(branches_list)
    bus_to_cluster(branches_list(i))=[];
    for j=1:length(clusters)
        if ismember(branches_list(i), clusters(j))
           bus_to_cluster(branches_list(i))=[bus_to_cluster(branches_list(i)), j]; 
        end
    end
end
end

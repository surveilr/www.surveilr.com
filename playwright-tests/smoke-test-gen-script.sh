#!/bin/bash

    psql -h 10.10.10.171 -p 6798 -U postgres -d configuration -t -A -F "\"" \
    -c "COPY (
         SELECT 
            'Tenant=''' || tm.tenant_name || ''' role=super_admin store=''' || sm.store_name || ''' url=''https://'|| tm.sub_domain || '''  npx playwright test --grep @smoke-high'
        FROM 
            stateful_service_bzo.tenant_master tm
        JOIN 
            stateful_service_bzo.store_master sm 
        ON 
            tm.tenant_id = sm.tenant_id
    ) TO STDOUT WITH CSV;" | sed '/^Time: /d' > smoke-test.auto.sh

    psql -h 10.10.10.171 -p 6798 -U postgres -d configuration -t -A -F "\"" \
    -c "COPY (
        SELECT 
            'Tenant=''' || tm.tenant_name || ''' role=admin store=''' || sm.store_name || ''' url=''https://'|| tm.sub_domain || ''' npx playwright test --grep @smoke-high'
        FROM 
            stateful_service_bzo.tenant_master tm
        JOIN 
            stateful_service_bzo.store_master sm 
        ON 
            tm.tenant_id = sm.tenant_id
    ) TO STDOUT WITH CSV;" | sed '/^Time: /d' >> smoke-test.auto.sh

        psql -h 10.10.10.171 -p 6798 -U postgres -d configuration -t -A -F "\"" \
    -c "COPY (
        SELECT 
            'Tenant=''' || tm.tenant_name || ''' role=user store=''' || sm.store_name || ''' url=''https://'|| tm.sub_domain || ''' npx playwright test --grep @smoke-high'
        FROM 
            stateful_service_bzo.tenant_master tm
        JOIN 
            stateful_service_bzo.store_master sm 
        ON 
            tm.tenant_id = sm.tenant_id
    ) TO STDOUT WITH CSV;" | sed '/^Time: /d' >> smoke-test.auto.sh


        psql -h 10.10.10.171 -p 6798 -U postgres -d configuration -t -A -F "\"" \
    -c "COPY (
        SELECT 
            'Tenant=''' || tm.tenant_name || ''' role=client store=''' || ''' url=''https://'|| tm.sub_domain || sm.store_name || ''' npx playwright test --grep @smoke-high'
        FROM 
            stateful_service_bzo.tenant_master tm
        JOIN 
            stateful_service_bzo.store_master sm 
        ON 
            tm.tenant_id = sm.tenant_id
    ) TO STDOUT WITH CSV;" | sed '/^Time: /d' >> smoke-test.auto.sh

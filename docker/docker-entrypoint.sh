#!/bin/sh
#

if [ $# -eq 0 ]; then
	echo
	echo "Starting OpenLDAP container..."

	OPENLDAP_ENDPOINTS="ldap://"
	OPENLDAP_SSL_CERT=""
	OPENLDAP_SSL_KEY=""

	if [ -n "${CONFIG_LEGO_DOMAIN}" ]; then
		if [ -z "${SSL_CERT_EXPIRE_TIMEOUT}" ]; then
			echo "A variable SSL_CERT_EXPIRE_TIMEOUT is not set. Cannot continue." >&2
			exit 12
		fi

		OPENLDAP_SSL_CERT="/data/etc/lego/certificates/${CONFIG_LEGO_DOMAIN}.crt"
		OPENLDAP_SSL_KEY="/data/etc/lego/certificates/${CONFIG_LEGO_DOMAIN}.key"

		OPENLDAP_ENDPOINTS="${OPENLDAP_ENDPOINTS} ldaps://"

		echo -n "Checking the certificate for exparation... "
		if [ -f "${OPENLDAP_SSL_CERT}" ] && openssl x509 -in "${OPENLDAP_SSL_CERT}" -noout -checkend "${SSL_CERT_EXPIRE_TIMEOUT}"; then
			echo
			echo "Certificate is good. No need to re-create."
		else
			echo
			echo "Certificate has been expired or will do so within ${SSL_CERT_EXPIRE_TIMEOUT} seconds!"

			echo
			echo "CONFIG_LEGO_DOMAIN is defined. Entering to SSL generation runtime..."

			if [ -z "${CONFIG_LEGO_EMAIL}" ]; then
				echo
				echo "CONFIG_LEGO_EMAIL is not defined. Cannot continue." >&2
				exit 63
			fi

			SOLVER_COUNT=0
			if [ "${CONFIG_LEGO_CHALLENGE_HTTP_01}" = "true" ]; then
				let "SOLVER_COUNT=${SOLVER_COUNT}+1"
			fi
			if [ "${CONFIG_LEGO_CHALLENGE_TLS_ALPN_01}" = "true" ]; then
				let "SOLVER_COUNT=${SOLVER_COUNT}+1"
			fi
			if [ -n "${CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER}" ]; then
				let "SOLVER_COUNT=${SOLVER_COUNT}+1"
			fi

			if [ ${SOLVER_COUNT} -lt 1 ]; then
				echo
				echo "Challange solver is not choosen. Define one of CONFIG_LEGO_CHALLENGE_HTTP_01, CONFIG_LEGO_CHALLENGE_TLS_ALPN_01 or CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER. Cannot continue." >&2
				exit 62
			fi

			LEGO_ENVS=""
			LEGO_OPTS="${CONFIG_LEGO_OPTS} --accept-tos --path /data/etc/lego --domains \"${CONFIG_LEGO_DOMAIN}\" --email \"${CONFIG_LEGO_EMAIL}\""

			if [ -n "${CONFIG_LEGO_CHALLENGE_HTTP_01}" ]; then
				echo
				echo "Using HTTP-01 challange solver. Make sure that your container available from Internet on port 80 and binds to domain(s): ${CONFIG_LEGO_DOMAIN}"
				LEGO_OPTS="${LEGO_OPTS} --http"
			fi
			if [ -n "${CONFIG_LEGO_CHALLENGE_TLS_ALPN_01}" ]; then
				echo
				echo "Using TLS-ALPN-01 challange solver. Make sure that your container available from Internet on port 443 and binds to domain(s): ${CONFIG_LEGO_DOMAIN}"
				LEGO_OPTS="${LEGO_OPTS} --tls"
			fi
			if [ -n "${CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER}" ]; then
				echo
				echo "Using DNS-01 challange solver. DNS Provider plugin: ${CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER}"
				if [ "${CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER}" = "exec" ]; then
					if [ -z "${EXEC_PATH}" ]; then
						echo
						echo "DNS-01 Challange solver requires variable EXEC_PATH. Cannot continue." >&2
						exit 61
					fi

					LEGO_ENVS="EXEC_MODE=default EXEC_PATH=\"${EXEC_PATH}\" ${LEGO_ENVS}"

					if [ -z "${EXEC_PROPAGATION_TIMEOUT}" ]; then
						echo
						echo "DNS-01 Challange solver requires variable EXEC_PROPAGATION_TIMEOUT. Cannot continue." >&2
						exit 62
					fi

					if [ -z "${EXEC_POLLING_INTERVAL}" ]; then
						echo
						echo "DNS-01 Challange solver requires variable EXEC_POLLING_INTERVAL. Cannot continue." >&2
						exit 63
					fi
				fi

				if [ -n "${CONFIG_LEGO_CHALLENGE_DNS_01_RESOLVERS}" ]; then
					for RESOLVER in $(echo ${CONFIG_LEGO_CHALLENGE_DNS_01_RESOLVERS} | sed 's/,/ /g'); do
						LEGO_OPTS="${LEGO_OPTS} --dns.resolvers ${RESOLVER}"
					done
					unset RESOLVER
				fi

				LEGO_OPTS="${LEGO_OPTS} --dns ${CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER}"
			fi

			LEGO_CMD="${LEGO_ENVS} lego ${LEGO_OPTS} run"
			echo
			echo "Obtain SSL certificate..."
			echo "${LEGO_CMD}"
			/bin/sh -c "${LEGO_CMD}"

			if [ $? -ne 0 ]; then
				echo
				echo "Failed to obtain SSL certificate" >&2
				exit 31
			fi

			chown -R ldap:ldap /data/etc/lego
		fi
	fi

	echo	
	echo "Sleeping for 5 seconds before start OpenLDAP..."
	sleep 5
	echo
	if [ "${CONFIG_OPENLDAP_MODE}" = "DIRECTORY" ]; then
		echo "Configuration mode: DIRECTORY. Using LDAP configuration directory /data/etc/slapd.d"

		if [ ! -d /data/etc/slapd.d ]; then
			echo
			echo "The directory /data/etc/slapd.d is not exist, so making initial setup..."

			mkdir /data/etc/slapd.d || exit 127

			echo
			echo "Preparing /tmp/setup.ldif..."

			echo "dn: cn=config" >> /tmp/setup.ldif
			echo "objectClass: olcGlobal" >> /tmp/setup.ldif
			echo "cn: config" >> /tmp/setup.ldif
			echo "olcPasswordHash: {SSHA}" >> /tmp/setup.ldif
			echo "olcArgsFile: /run/slapd/slapd.args" >> /tmp/setup.ldif
			echo "olcPidFile: /run/slapd/slapd.pid" >> /tmp/setup.ldif
			if [ -n "${OPENLDAP_SSL_CERT}" -a -n "${OPENLDAP_SSL_KEY}" ]; then
				echo "olcTLSCertificateFile: ${OPENLDAP_SSL_CERT}" >> /tmp/setup.ldif
				echo "olcTLSCertificateKeyFile: ${OPENLDAP_SSL_KEY}" >> /tmp/setup.ldif
			fi

			echo >> /tmp/setup.ldif
			echo "dn: olcDatabase=config,cn=config" >> /tmp/setup.ldif
			echo "objectClass: olcDatabaseConfig" >> /tmp/setup.ldif
			echo "olcDatabase: config" >> /tmp/setup.ldif
			echo "olcAccess: to * by * none" >> /tmp/setup.ldif
			echo "olcRootDN: cn=config" >> /tmp/setup.ldif
			# Password: openldap
			echo "olcRootPW: {SSHA}VP9RG/n2DkMGlDP+/A80uEZLtRHhUxuR" >> /tmp/setup.ldif

			echo
			echo "Generating configuration directory /data/etc/slapd.d..."

			echo
			slapadd -F /data/etc/slapd.d -n 0 -l /tmp/setup.ldif
			if [ $? -ne 0 ]; then
				echo
				echo "Failed to configure directory /data/etc/slapd.d" >&2
				exit 2
			fi

			rm /tmp/setup.ldif

			if [ -d /data/etc/slapd-init.d ]; then
				echo
				echo "Apply /data/etc/slapd-init.d LDIF files..."
				for F in $(find /data/etc/slapd-init.d -name '*.ldif' | sort); do
					echo
					echo "	${F}"
					echo
					slapadd -F /data/etc/slapd.d -n 0 -l "${F}"
					if [ $? -ne 0 ]; then
						echo
						echo "Failed to add ${F} into configuration directory /data/etc/slapd.d" >&2
						exit 6
					fi
				done
			fi

			chown -R ldap:ldap /data/etc/slapd.d
		fi

		# Prepare OpenLDAP stuff
		mkdir -p /run/slapd || exit 126
		chown ldap:ldap /run/slapd || exit 125
		# Run OpenLDAP
		echo
		echo "Starting slapd..."
		OPENLDAP_CMD="slapd -d \"${SLAPD_DEBUG_LEVEL}\" -u ldap -g ldap -F /data/etc/slapd.d -h \"${OPENLDAP_ENDPOINTS}\""
		echo
		echo "	${OPENLDAP_CMD}"
		echo
		exec /bin/sh -c "exec ${OPENLDAP_CMD}"
	else
		echo "Non supported configuration mode ${CONFIG_OPENLDAP_MODE}" >&2
		exit 1;
	fi

else
	echo "Right now the container support launch only as 'root' user." >&2
	exit 128
fi


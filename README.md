# Archiver Appliance Containerisation

ISIS Container config for the EPICS Archiver Appliance.

For a more detailed description and usage, see the [wiki page](https://github.com/ISISComputingGroup/ibex_developers_manual/wiki/Containerising-the-Archiver-Appliance)

## Developer setup

- Copy and fill in contents of `.env.example` file to `.env` file. `.env` is listed in `.gitignore`, do not check this file into version control.
- Ensure you have WSL correctly installed.
- Ensure you have rancher desktop (or another suitable container runner) installed and working.
- Ensure you have `GWCONTAINER` running on the local host (specified in `.env`).
  * You will need a reasonably recent checkout of top-level EPICS, and then a restart of IBEX server, for this.
- Run `nerdctl compose -f docker-compose.yaml up` to bring up the container. Give it several minutes to start and connect properly.
- Go to `http://localhost:17665/mgmt/ui/index.html` in your web browser, you should see an archive appliance UI.

## Useful Info

- Developer archived data is stored under `\\isisarvr3\archiveappliancetest$`

### Policies Configuration

- When configuring data storage URLs you can use the following useful actions:
  - `partitionGranularity` - The base period of time between when ETL runs e.g PARTITION_HOUR
  - `hold` - How many of the partitionGranularity to wait until ETL runs.
  - `gather` - When ETL runs, how many partitions should be moved to the next storage state. "For example, `hold=5&gather=3` lets you keep at least `5-3=2` partitions in this store. ETL kicks in once the oldest event is older than than `5` partitions and data is moved `3` partitions at a time."
  - `pp` - After moving data to a new store, perform a post processing action, e.g decimation `optimized=25` which will look at all the samples you have in a partition and lower its resolution to `25` samples.

### Commands
Show the running containers:
`nerdctl.exe ps -all`

Stop the container:
`nerdctl compose -f docker-compose.yaml down`

Stop, rebuild & restart container (without cached images):
`nerdctl compose -f docker-compose.yaml down && nerdctl compose -f docker-compose.yaml build --no-cache && nerdctl compose -f docker-compose.yaml up`

To run a bash session on the running container:
`nerdctl exec -it my_aa /bin/bash`

To list ports used by process ID:
`netstat -p tcp -ano`

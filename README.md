# Archiver Appliance Containerisation

ISIS Container config for the EPICS Archiver Appliance.

For a more detailed description and usage, see the [wiki page](https://github.com/ISISComputingGroup/ibex_developers_manual/wiki/Containerising-the-Archiver-Appliance)

## Developer setup

- Copy the `.env.example` file to `.env` and fill in the relevant details. `.env` is in `.gitignore`, do not check this file into version control.
- Ensure you have rancher desktop (or another suitable container runner) installed and working.
- Ensure you have `GWCONTAINER` running on the local host (specified in `.env`).
  * You will need a reasonably recent checkout of top-level EPICS, and then a restart of IBEX server, for this.
- Run `nerdctl compose -f docker-compose.yaml up` to bring up the container. Give it several minutes to start and connect properly.
- Go to `http://localhost:17665/mgmt/ui/index.html` in your web browser, you should see an archive appliance UI.

## Some useful commands
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

# Archiver Appliance Containerisation
    This is the expeimental development to containerise the EPICS Archiver Appliance, archiving PV data from localhost as well as the external gateway.

A description of the files in this repo:
| File | Description |
| ---- | ----------- |
| Containerfile | Defines the content to build into the image |
| aa-compose.yaml | Used by `nerdctl compose` to marshall building the image and running the container  |
| docker-compose.yaml | This was used as an experimental compose file to test various networking options to try to circumvent Windows lack of 'host' container networking. Retained as there is some useful info and techniques |
| containerdata  | This directory is mounted by the container and facilitates data persistence  |
| test\Containerfile | Build specification for the stress test image |
| test\stress-test.py | A simple prime number generator that gets incorporated within the built stress-test image |

## Some useful commands
Show the running containers:
`nerdctl.exe ps -all`

Stop the container:
`nerdctl.exe stop isis-aa-<number>`

Run the container:
`nerdctl run -it --rm -p17665:17665 isis-aa`

Initially add these to the archiver appliance:
```
TE:NDW2920:DAE:RUNSTATE
TE:NDW2920:DAE:GOODFRAMES
IN:ZOOM:DAE:RUNSTATE
```

To run a bash session on the running container:
nerdctl.exe exec -it isis-aa-<number> bash

To list ports used by process ID:
`netstat -p tcp -ano`

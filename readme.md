# Jamf Migration Helper
Automatically remove Macs or devices (iPad, iPhone, Apple TV) after they have successfully enrolled on the new Jamf server, from the old Jamf server to maintain accurate device counts and an overview of our migration status. 

These scripts are intended to be run automatically on a recurring scheduled basis. It downloads a list of all computers/devices enrolled with your new production server and locates the serial numbers for each enrolled computer/device and submits a DELETE request using the Jamf API to the legacy server to remove its object. 

These scripts are not very smart, and does not do much verification. The reason for this is it was used in our environment in support of a gradual migration between Jamf servers where we leveraged `erase install` to fully erase shared Macs in labs on campus. Because these are shared Macs, they store no user data and we do not need to retain objects in Jamf past active use. 

We needed to do this for multiple reasons, including support and reporting reasons. We wanted to reduce confusion with Macs appearing on both Jamf servers during our gradual rolling migration, and we wanted to easily get an overview of how many devices we have left to transition from the legacy server to the production server. 

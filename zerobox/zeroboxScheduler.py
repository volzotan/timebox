from datetime import datetime, timedelta

class Scheduler(object):

    def __init__(self):
        self.jobs = []

    # def start(self):
    #     pass


    # def stop(self):
    #     pass

    def add_job(self, job_object, interval, delay=None):
        new_job = {}
        new_job["start"] = datetime.now()
        if delay is not None:
            new_job["start"] = new_job["start"] + timedelta(milliseconds=int(delay))
        new_job["interval"] = timedelta(milliseconds=int(interval))
        new_job["last_invocation"] = None
        new_job["next_invocation"] = new_job["start"]
        new_job["job_object"] = job_object
        self.jobs.append(new_job)


    def is_job_scheduled(self, job_object):
        for job in self.jobs:
            if job["job_object"] == job_object:
                return True

        return False


    def remove_job(self, job_object):
        job_to_remove = None
        for job in self.jobs:
            if job["job_object"] == job_object:
                job_to_remove = job
                break

        if job_to_remove is None:
            raise Exception("job not found")

        self.jobs.remove(job_to_remove)


    def info(self):
        return self.jobs


    def get_next_invocation(self, job_object):
        for job in self.jobs:
            if job["job_object"] == job_object:
                return job["next_invocation"]

        return None


    def print_next_job(self):

        jobs_sorted = sorted(self.jobs, key = lambda i: i["next_invocation"]) 

        for job in jobs_sorted:
            delta = job["next_invocation"] - datetime.now()
            if delta.total_seconds() > 0:
                return "next job: {} in {:.2f}s".format(job["job_object"], delta.total_seconds())


    def run_schedule(self):
        triggered_jobs = []

        for job in self.jobs:
            if job["next_invocation"] < datetime.now():
                job["last_invocation"] = datetime.now()
                while job["next_invocation"] < datetime.now():
                    job["next_invocation"] = job["next_invocation"] + job["interval"]
                triggered_jobs.append(job["job_object"])

        # remove duplicates
        triggered_jobs = list(set(triggered_jobs))

        return triggered_jobs


if __name__ == "__main__":
    while True:
        pass
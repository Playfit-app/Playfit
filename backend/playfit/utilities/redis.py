import redis
from django.conf import settings

# Use settings for Redis configuration if needed
REDIS_HOST = getattr(settings, "REDIS_HOST")
REDIS_PORT = getattr(settings, "REDIS_PORT")
REDIS_DB = getattr(settings, "REDIS_DB")

redis_client = redis.StrictRedis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, decode_responses=True)
